extends Control

var current_model: Node3D

@onready var model_manager = %ModelManager

@onready var pick_model_panel = %PickModelPanel
@onready var preview_window = %PreviewWindow
@onready var animation_preview = %AnimationPreview

func load_model(path: String):
	current_model = model_manager.load_model(path)
	preview_window.set_model(current_model)
	animation_preview.set_available_animations(current_model.get_available_animations())
