extends Control

signal on_model_rotation_changed(model_rotation: float)
signal on_camera_offset_changed(offset_x: float, offset_y: float)

@onready var x_spin_box = %XSpinBox
@onready var y_spin_box = %YSpinBox

func _on_model_rotation_slider_value_changed(value):
	on_model_rotation_changed.emit(value)

func _on_cam_offset_changed():
	on_camera_offset_changed.emit(x_spin_box.value, y_spin_box.value)
