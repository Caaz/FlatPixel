class_name PaletteColorPicker
extends HBoxContainer

signal on_palette_color_updated(color: Color)
signal on_remove

@onready var color_picker_button: ColorPickerButton = %ColorPickerButton

func get_color() -> Color:
	return color_picker_button.color

func set_color(color: Color):
	color_picker_button.color = color

func _on_color_picker_button_color_changed(color: Color) -> void:
	on_palette_color_updated.emit(color)

func _on_remove_button_pressed() -> void:
	on_remove.emit()
