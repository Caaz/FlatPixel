extends Control

signal on_animation_settings_changed(settings: AnimationSettings)

@onready var animation_selector = %AnimationSelector

var current_settings: AnimationSettings = AnimationSettings.new()

func set_available_animations(animations: PackedStringArray):
	animation_selector.clear()
	for item in animations:
		animation_selector.add_item(item)

func _on_animation_selector_item_selected(index):
	current_settings.current_animation = animation_selector.get_item_text(index)
	on_animation_settings_changed.emit(current_settings)

func _on_play_button_pressed():
	current_settings.is_playing = true
	on_animation_settings_changed.emit(current_settings)

func _on_pause_button_pressed():
	current_settings.is_playing = false
	on_animation_settings_changed.emit(current_settings)
