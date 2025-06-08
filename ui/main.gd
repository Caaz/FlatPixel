extends Control

var current_model: Node3D

@onready var model_manager = %ModelManager
@onready var spritesheet_renderer = %SpritesheetRenderer

@onready var pick_model_panel = %PickModelPanel
@onready var preview_window = %PreviewWindow
@onready var animation_preview = %AnimationPreview
@onready var camera_control = %CameraControl
@onready var render_control = %RenderControl

func load_model(path: String):
	current_model = model_manager.load_model(path)
	var preview_dummy = preview_window.set_model(current_model)
	animation_preview.set_available_animations(preview_dummy.get_available_animations())

func render_spritesheet(path: String):
	spritesheet_renderer.render_spritesheet(
		current_model, 
		camera_control.current_settings, 
		render_control.current_settings,
		animation_preview.current_settings,
		path
	)
