extends Node

signal on_render_start(title: String)
signal on_render_finish
signal on_render_progress_update(current_frame: int, total_frames: int, current_anim: int, total_anims: int)

@onready var world: SubViewport = %World
@onready var simulation: SimulationWorld = %SimulationWorld

var rendering: bool = false

var current_animation_idx: int
var total_animations: int

func build_render(render_normals: bool = true) -> RenderResult:
	if rendering:
		return RenderResult.new([] as Array[Image], [] as Array[Image])
	
	var now = Time.get_ticks_msec()
	
	on_render_start.emit("Diffuse")
	rendering = true
	
	var diffuse_result = await render_frames(false)
	
	var normal_result = ([] as Array[Image])
	if render_normals:
		on_render_start.emit("Normal")
		normal_result = await render_frames(true)
	
	rendering = false
	
	on_render_finish.emit()
	
	var time_consumed = Time.get_ticks_msec() - now
	
	var render_result = RenderResult.new(diffuse_result.frames, normal_result.frames)
	render_result.render_duration_ms = time_consumed
	render_result.animation_details = diffuse_result.animation_details
	render_result.render_resolution = Session.render_settings.resolution
	render_result.render_fps = Session.render_settings.render_fps
	return render_result

func render_frames(use_normal: bool = false) -> RenderSubresult:
	if Session.capture_model == null:
		return RenderSubresult.new()
	var capture_model = Session.capture_model.duplicate() as CaptureModel
	
	simulation.set_model(capture_model)
	simulation.set_camera_settings(Session.camera_settings)
	simulation.set_render_settings(Session.render_settings)
	simulation.set_normals(use_normal)
	world.size = Session.render_settings.resolution
	
	var fps = Session.render_settings.render_fps
	
	var images: Array[Image] = []
	var animation_details: Array[AnimationDetails] = []
	
	var use_turntable = Session.camera_settings.turntable_steps > 1
	var turntable_steps = Session.camera_settings.turntable_steps if use_turntable else 1
	var turntable_rotation_degrees = 360.0 / turntable_steps if use_turntable else 0.0
	
	if is_instance_valid(capture_model.animation_player):
		# If the capture model has an animation player, it has animation for us to process.
		var target_animations = Session.model_settings.selected_animations \
			if len(Session.model_settings.selected_animations) > 0 \
			else PackedStringArray([Session.preview_settings.previewed_animation])
		
		total_animations = len(target_animations) * (turntable_steps if use_turntable else 1)
		current_animation_idx = 0
		
		var total_frames_processed = 0
		
		for anim in target_animations:
			for turntable_step in range(turntable_steps):
				var turntable_step_rotation = turntable_step * turntable_rotation_degrees
				
				simulation.set_turntable_angle(turntable_step_rotation)
				
				var anim_frames = await _render_animation(capture_model, anim, fps)
				images.append_array(anim_frames)
				
				# Save off animation details for later
				var anim_details = AnimationDetails.new()
				anim_details.animation_name = anim if not use_turntable else "%s-%sdeg" % [anim, str(int(turntable_step_rotation))]
				anim_details.frame_start = total_frames_processed
				anim_details.frame_end = total_frames_processed + len(anim_frames) - 1
				animation_details.append(anim_details)
				
				total_frames_processed += len(anim_frames)
				
				current_animation_idx += 1
	
	else:
		# Else, return a still
		images.append(await capture_frame(capture_model, 0, 1))
	
	capture_model.queue_free()
	
	var result = RenderSubresult.new()
	result.frames = images
	result.animation_details = animation_details
	return result

func _render_animation(capture_model: CaptureModel, animation: String, render_fps: float) -> Array[Image]:
	# Load in animation, but don't actively play as we will scrub through manually
	capture_model.play_animation(animation)
	capture_model.pause_animation()
	
	# Wait one frame to let things settle
	await get_tree().process_frame
	
	return await get_all_frames(capture_model, render_fps)

func get_all_frames(capture_model: CaptureModel, render_fps: float) -> Array[Image]:
	var num_frames := roundi(capture_model.animation_player.current_animation_length * render_fps)
	var images: Array[Image] = []
	for i in range(num_frames):
		images.append(await capture_frame(capture_model, i, render_fps))
		on_render_progress_update.emit(i, num_frames, current_animation_idx, total_animations)
	return images

func capture_frame(capture_model: CaptureModel, frame_idx: int, render_fps: float) -> Image:
	capture_model.set_animation_position(frame_idx * (1.0 / render_fps))
	return await get_viewport_image()

func get_viewport_image() -> Image:
	# Signal must be awaited before grabbing next frame!
	await RenderingServer.frame_post_draw
	return world.get_texture().get_image()

func merge_frames(frames: Array[Image]) -> Image:
	var num_frames = len(frames)
	var columns = Session.export_settings.spritesheet_columns
	var rows = ceili(num_frames / float(columns))
	
	var frame_size: Vector2i = frames[0].get_size()
	var spritesheet_size: Vector2i = Vector2i(frame_size.x * columns, frame_size.y * rows)
	
	var spritesheet = Image.create(spritesheet_size.x, spritesheet_size.y, false, frames[0].get_format())
	
	for i in range(len(frames)):
		var col_idx = i % columns
		var row_idx = floor(i / float(columns))
		var frame = frames[i]
		for x in range(frame.get_width()):
			for y in range(frame.get_height()):
				spritesheet.set_pixel(x + col_idx * frame_size.x, y + row_idx * frame_size.y, frame.get_pixel(x, y))

	return spritesheet
