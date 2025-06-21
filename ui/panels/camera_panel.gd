extends MarginContainer

@onready var model_rotation_slider: Slider = %ModelRotationSlider
@onready var model_rotation_spin_box: SpinBox = %ModelRotationSpinBox

@onready var offset_x_spin_box: SpinBox = %XSpinBox
@onready var offset_y_spin_box: SpinBox = %YSpinBox
@onready var offset_z_spin_box: SpinBox = %ZSpinBox

@onready var tilt_spin_box: SpinBox = %TiltSpinBox

@onready var projection_option_button: OptionButton = %ProjectionOptionButton

@onready var ortho_only_v_box: VBoxContainer = %OrthoOnlyVBox
@onready var ortho_size_spin_box: SpinBox = %OrthoSizeSpinBox
@onready var perspective_only_v_box: VBoxContainer = %PerspectiveOnlyVBox
@onready var perspective_fov_spin_box: SpinBox = %PerspectiveFovSpinBox

@onready var turntable_off_button: Button = %OffButton
@onready var turntable_four_direction_button: Button = %FourDirectionButton
@onready var turntable_eight_direction_button: Button = %EightDirectionButton

func _ready():
	Session.on_flpx_loaded.connect(_on_flpx_loaded)
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
	
	settings.turntable_steps = _get_turntable_value()
	
	Session.set_camera_settings(settings)

func _get_turntable_value():
	if turntable_off_button.button_pressed:
		return 1
	elif turntable_four_direction_button.button_pressed:
		return 4
	elif turntable_eight_direction_button.button_pressed:
		return 8

func _autoframe():
	var aabb = Session.capture_model.get_aabb()
	print("Model aabb: ", aabb)
	var center = aabb.get_center()
	print("Center: ", center)
	offset_x_spin_box.value = center.x
	offset_y_spin_box.value = center.y
	_on_value_changed()

func _on_flpx_loaded():
	model_rotation_slider.set_value_no_signal(Session.camera_settings.model_rotation)
	model_rotation_spin_box.set_value_no_signal(Session.camera_settings.model_rotation)
	
	offset_x_spin_box.set_value_no_signal(Session.camera_settings.camera_offset.x)
	offset_y_spin_box.set_value_no_signal(Session.camera_settings.camera_offset.y)
	offset_z_spin_box.set_value_no_signal(Session.camera_settings.camera_offset.z)
	
	tilt_spin_box.set_value_no_signal(Session.camera_settings.camera_tilt)
	
	projection_option_button.selected = 0 if Session.camera_settings.ortho_camera else 1
	ortho_only_v_box.visible = Session.camera_settings.ortho_camera
	perspective_only_v_box.visible = not Session.camera_settings.ortho_camera
	
	ortho_size_spin_box.set_value_no_signal(Session.camera_settings.ortho_camera_size)
	perspective_fov_spin_box.set_value_no_signal(Session.camera_settings.perspective_camera_fov)
	
	turntable_off_button.button_pressed = Session.camera_settings.turntable_steps == 1
	turntable_four_direction_button.button_pressed = Session.camera_settings.turntable_steps == 4
	turntable_eight_direction_button.button_pressed = Session.camera_settings.turntable_steps == 8
