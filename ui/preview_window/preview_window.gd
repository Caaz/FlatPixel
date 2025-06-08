extends Control

@onready var world = %World
@onready var simulation = %SimulationWorld
@onready var viewport_view = %ViewportView

var preview_dummy: CaptureModel

func set_model(node: Node3D):
	preview_dummy = node.duplicate() as CaptureModel
	simulation.set_model(preview_dummy)
	return preview_dummy

func set_camera_settings(settings: CameraSettings):
	simulation.set_camera_settings(settings)

func set_render_settings(settings: RenderSettings):
	world.size = settings.resolution
	simulation.set_render_settings(settings)

func set_animation_settings(settings: AnimationSettings):
	preview_dummy.play_animation(settings.current_animation)
	if not settings.is_playing:
		preview_dummy.pause_animation()

func get_viewport_image() -> Image:
	return (viewport_view.texture as ViewportTexture).get_image()
