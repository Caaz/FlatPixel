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
	
	
	on_render_start.emit("Diffuse")
	rendering = true
	
	var diffuse_result = await render_frames(false)
	
	var normal_result = ([] as Array[Image])
	if render_normals:
		on_render_start.emit("Normal")
		normal_result = await render_frames(true)
	
	rendering = false
	
	on_render_finish.emit()
	
	return RenderResult.new(diffuse_result, normal_result)

func render_frames(use_normal: bool = false) -> Array[Image]:
	if Session.capture_model == null:
		return ([] as Array[Image])
	var capture_model = Session.capture_model.duplicate() as CaptureModel
	
	simulation.set_model(capture_model)
	simulation.set_camera_settings(Session.camera_settings)
	simulation.set_render_settings(Session.render_settings)
	simulation.set_normals(use_normal)
	world.size = Session.render_settings.resolution
	
	var fps = Session.render_settings.render_fps
	
	var images: Array[Image] = []
	
	total_animations = len(Session.model_settings.selected_animations)
	current_animation_idx = 0
	
	for anim in Session.model_settings.selected_animations:
		var anim_frames = await _render_animation(capture_model, anim, fps)
		images.append_array(anim_frames)
		current_animation_idx += 1
	
	capture_model.queue_free()
	return images

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
	var rows = ceil(num_frames / float(columns))
	
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
