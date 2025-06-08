extends Control

signal on_camera_settings_changed(new_settings: CameraSettings)

@onready var model_rotation_slider = %ModelRotationSlider
@onready var model_rotation_spin_box = %ModelRotationSpinBox

@onready var x_spin_box = %XSpinBox
@onready var y_spin_box = %YSpinBox
@onready var z_spin_box = %ZSpinBox

@onready var tilt_spin_box = %TiltSpinBox

var current_settings: CameraSettings

func _ready():
	_on_value_changed()

func _on_value_changed():
	current_settings = CameraSettings.new()
	
	current_settings.model_rotation = model_rotation_spin_box.value
	current_settings.camera_offset = Vector3(
		x_spin_box.value, y_spin_box.value, z_spin_box.value
	)
	current_settings.camera_tilt = tilt_spin_box.value
	
	on_camera_settings_changed.emit(current_settings)
