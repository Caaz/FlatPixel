extends MarginContainer

@export var animation_toggle_scene: PackedScene

@onready var animations_container: VBoxContainer = %AnimationsVBox

func _ready():
	Session.on_model_updated.connect(_on_model_updated)
	Session.on_flpx_loaded.connect(_on_flpx_loaded)

func on_model_path_selected(filepath: String):
	Session.load_model(filepath)

func _load_flpx(filepath: String):
	Session.load_flpx_file(filepath)

func _on_model_updated():
	for child in animations_container.get_children():
		child.queue_free()
	
	for anim_name in Session.model_settings.available_animations:
		var toggle := animation_toggle_scene.instantiate() as CheckBox
		toggle.text = anim_name
		toggle.toggled.connect(_on_animation_toggled.bind(anim_name))
		animations_container.add_child(toggle)

func _on_animation_toggled(state: bool, anim_name: String):
	if state:
		if not anim_name in Session.model_settings.selected_animations:
			Session.model_settings.selected_animations.append(anim_name)
	else:
		if anim_name in Session.model_settings.selected_animations:
			Session.model_settings.selected_animations.remove_at(Session.model_settings.selected_animations.find(anim_name))

func _select_all_animations():
	for child in animations_container.get_children():
		child.button_pressed = true

func _deselect_all_animations():
	for child in animations_container.get_children():
		child.button_pressed = false

func _on_flpx_loaded():
	for child in animations_container.get_children():
		child.set_pressed_no_signal(child.text in Session.model_settings.selected_animations)
