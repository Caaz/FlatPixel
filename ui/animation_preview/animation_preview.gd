extends Control

signal animation_selected(animation: String)
signal play
signal pause

@onready var animation_selector = %AnimationSelector

func set_available_animations(animations: PackedStringArray):
	animation_selector.clear()
	for item in animations:
		animation_selector.add_item(item)


func _on_animation_selector_item_selected(index):
	animation_selected.emit(animation_selector.get_item_text(index))

func _on_play_button_pressed():
	play.emit()

func _on_pause_button_pressed():
	pause.emit()
