extends MarginContainer

signal on_render_settings_changed(new_settings: RenderSettings)
signal on_render_spritesheet_requested(output_path: String)

@onready var x_spin_box = %XSpinBox
@onready var y_spin_box = %YSpinBox

@onready var render_normal_checkbox = %RenderNormalCheckbox

@onready var fps_spin_box = %FPSSpinBox

var current_settings: RenderSettings

func _ready():
	_on_value_changed()

func _on_value_changed():
	current_settings = RenderSettings.new()
	
	current_settings.resolution = Vector2i(int(x_spin_box.value), int(y_spin_box.value))
	current_settings.render_normal_map = render_normal_checkbox.is_pressed()
	current_settings.render_fps = int(fps_spin_box.value)
	
	on_render_settings_changed.emit(current_settings)


func _on_render_spritesheet_button_pressed():
	on_render_spritesheet_requested.emit("")
