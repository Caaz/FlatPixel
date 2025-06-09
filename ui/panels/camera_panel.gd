extends MarginContainer

@onready var model_rotation_slider = %ModelRotationSlider
@onready var model_rotation_spin_box = %ModelRotationSpinBox

@onready var offset_x_spin_box = %XSpinBox
@onready var offset_y_spin_box = %YSpinBox
@onready var offset_z_spin_box = %ZSpinBox

@onready var tilt_spin_box = %TiltSpinBox

@onready var projection_option_button: OptionButton = %ProjectionOptionButton

@onready var ortho_only_v_box: VBoxContainer = %OrthoOnlyVBox
@onready var ortho_size_spin_box: SpinBox = %OrthoSizeSpinBox
@onready var perspective_only_v_box: VBoxContainer = %PerspectiveOnlyVBox
@onready var perspective_fov_spin_box: SpinBox = %PerspectiveFovSpinBox

var current_settings: CameraSettings

func _ready():
	_on_value_changed.call_deferred()

func _on_value_changed():
	var settings = CameraSettings.new()
	
	settings.model_rotation = model_rotation_spin_box.value
	settings.camera_offset = Vector3(
		offset_x_spin_box.value, offset_y_spin_box.value, offset_z_spin_box.value
	)
	settings.camera_tilt = tilt_spin_box.value
	
	settings.ortho_camera = projection_option_button.get_selected_id() == 0
	
	# Set up other UI properly
	ortho_only_v_box.visible = settings.ortho_camera
	perspective_only_v_box.visible = not settings.ortho_camera
	
	settings.ortho_camera_size = ortho_size_spin_box.value
	settings.perspective_camera_fov = perspective_fov_spin_box.value
	
	Session.set_camera_settings(settings)

func _autoframe():
	var aabb = Session.capture_model.get_aabb()
	var center = aabb.get_center()
	offset_x_spin_box.value = center.x
	offset_y_spin_box.value = center.y
	_on_value_changed()
