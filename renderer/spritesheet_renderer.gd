extends Node

@onready var world: SubViewport = %World
@onready var simulation: SimulationWorld = %SimulationWorld

var capture_model: CaptureModel
var camera_settings: CameraSettings
var render_settings: RenderSettings
var animation_settings: AnimationSettings

func render_spritesheet(model: CaptureModel, camera_settings: CameraSettings, render_settings: RenderSettings, animation_settings: AnimationSettings, output_path: String):
	self.camera_settings = camera_settings
	self.render_settings = render_settings
	self.animation_settings = animation_settings
	
	world.size = render_settings.resolution
	
	capture_model = model.duplicate() as CaptureModel
	simulation.set_model(capture_model)
	simulation.set_camera_settings(camera_settings)
	simulation.set_render_settings(render_settings)
	
	# Wait one frame to let things settle
	await get_tree().process_frame
	
	capture_model.play_animation(animation_settings.current_animation)
	#capture_model.pause_animation()
	
	# Wait one frame to let things settle
	await get_tree().process_frame
	
	var frames = await get_all_frames()
	var spritesheet = merge_frames(frames)
	spritesheet.save_png("user://test.png")
	
	simulation.set_model(null)

func get_all_frames() -> Array[Image]:
	var num_frames = capture_model.animation_player.current_animation_length * render_settings.render_fps
	var images: Array[Image] = []
	for i in range(num_frames):
		images.append(await get_viewport_image())
	return images

func capture_frame(frame_idx: int) -> Image:
	capture_model.set_animation_position(frame_idx * (1.0 / render_settings.render_fps))
	return await get_viewport_image()

func get_viewport_image() -> Image:
	# Signal must be awaited before grabbing next frame!
	await get_tree().process_frame
	return world.get_texture().get_image()

func merge_frames(frames: Array[Image]) -> Image:
	var num_frames = len(frames)
	var columns = 8
	var rows = ceil(num_frames / float(columns))
	
	var frame_size: Vector2i = frames[0].get_size()
	var spritesheet_size: Vector2i = Vector2i(frame_size.x * columns, frame_size.y * rows)
	
	var spritesheet = Image.create(spritesheet_size.x, spritesheet_size.y, false, frames[0].get_format())
	
	for i in range(len(frames)):
		var col_idx = i % 8
		var row_idx = floor(i / 8.0)
		var frame = frames[i]
		for x in range(frame.get_width()):
			for y in range(frame.get_height()):
				spritesheet.set_pixel(x + col_idx * frame_size.x, y + row_idx * frame_size.y, frame.get_pixel(x, y))

	return spritesheet
