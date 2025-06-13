extends Control

@onready var world = %World
@onready var simulation := %SimulationWorld as SimulationWorld
@onready var viewport_view = %ViewportView

@onready var preview_animation_option_button: OptionButton = %PreviewAnimationOptionButton
@onready var animation_time_slider: HSlider = %AnimationTimeSlider

var preview_dummy: CaptureModel

func _ready():
	Session.on_model_updated.connect(_on_model_updated)
	Session.on_camera_settings_updated.connect(_on_camera_settings_updated)
	Session.on_render_settings_updated.connect(_on_render_settings_updated)

func _process(_delta: float):
	if preview_dummy and preview_dummy.animation_player.is_playing():
		animation_time_slider.set_value_no_signal(
			preview_dummy.animation_player.current_animation_position / preview_dummy.animation_player.current_animation_length
		)

func _on_model_updated():
	set_model(Session.capture_model.duplicate())
	
	preview_animation_option_button.clear()
	for anim in Session.model_settings.available_animations:
		preview_animation_option_button.add_item(anim)
	preview_animation_option_button.select(0)
	set_model_animation_idx(0)
	pause_model_animation()

func _on_camera_settings_updated():
	set_camera_settings(Session.camera_settings)

func _on_render_settings_updated():
	set_render_settings(Session.render_settings)

func set_model(node: CaptureModel):
	preview_dummy = node.duplicate() as CaptureModel
	simulation.set_model(preview_dummy)
	return preview_dummy

func set_camera_settings(settings: CameraSettings):
	simulation.set_camera_settings(settings)

func set_render_settings(settings: RenderSettings):
	world.size = settings.resolution
	simulation.set_render_settings(settings)

func get_viewport_image() -> Image:
	return (viewport_view.texture as ViewportTexture).get_image()

func set_model_animation_idx(idx: int):
	set_model_animation(preview_animation_option_button.get_item_text(idx))

func set_model_animation(animation: String):
	if not preview_dummy:
		return
	preview_dummy.play_animation(animation)

func play_model_animation():
	if not preview_dummy:
		return
	preview_dummy.resume_animation()

func pause_model_animation():
	if not preview_dummy:
		return
	preview_dummy.pause_animation()

func set_preview_normals(state: bool):
	simulation.set_normals(state)


func _on_animation_time_slider_value_changed(value: float) -> void:
	if preview_dummy:
		preview_dummy.animation_player.seek(preview_dummy.animation_player.current_animation_length * value, true)
