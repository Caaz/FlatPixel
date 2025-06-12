extends MarginContainer

@export var palette_color_picker_scene: PackedScene

@onready var x_spin_box = %XSpinBox
@onready var y_spin_box = %YSpinBox

@onready var fps_spin_box = %FPSSpinBox

@onready var color_quantization_checkbox: CheckBox = %ColorQuantizationCheckbox
@onready var palette_v_box: VBoxContainer = %PaletteVBox

@onready var render_spritesheet_button: Button = %RenderSpritesheetButton

var color_pickers: Array[PaletteColorPicker] = []

func _ready():
	Session.on_flpx_loaded.connect(_on_flpx_loaded)
	SpritesheetRenderer.on_render_start.connect(render_spritesheet_button.set_disabled.bind(true).unbind(1))
	SpritesheetRenderer.on_render_finish.connect(render_spritesheet_button.set_disabled.bind(false))
	_on_value_changed.call_deferred()

func _on_value_changed():
	var settings = RenderSettings.new()
	
	settings.resolution = Vector2i(int(x_spin_box.value), int(y_spin_box.value))
	settings.render_fps = int(fps_spin_box.value)
	
	settings.use_color_quantization = color_quantization_checkbox.button_pressed
	settings.quantization_palette = _get_current_palette()
	
	Session.set_render_settings(settings)

func _get_current_palette() -> Array[Color]:
	var palette: Array[Color] = []
	for picker in color_pickers:
		palette.append(picker.get_color())
	return palette

func _construct_palette_picker() -> PaletteColorPicker:
	var picker := palette_color_picker_scene.instantiate() as PaletteColorPicker
	picker.on_palette_color_updated.connect(_on_value_changed.unbind(1))
	picker.on_remove.connect(_remove_palette_color.bind(picker))
	color_pickers.append(picker)
	palette_v_box.add_child(picker)
	return picker

func _add_palette_color():
	_construct_palette_picker()
	_on_value_changed()

func _add_color_to_palette(color: Color):
	var picker := _construct_palette_picker()
	picker.set_color(color)
	_on_value_changed()

func _add_color_to_palette_no_signal(color: Color):
	var picker := _construct_palette_picker()
	picker.set_color(color)

func _remove_palette_color(picker: PaletteColorPicker):
	color_pickers.erase(picker)
	picker.queue_free()
	_on_value_changed()

func _clear_palette():
	for picker in color_pickers:
		picker.queue_free()
	color_pickers.clear()

func _load_palette_from_path(path: String):
	_clear_palette()
	var palette_colors := PaletteHelper.palette_from_image_path(path)
	for color: Color in palette_colors:
		_add_color_to_palette(color)

func _save_palette_to_path(path: String):
	var palette = _get_current_palette()
	PaletteHelper.save_palette_to_path(palette, path)

func _run_render():
	Session.run_render()

func _on_flpx_loaded():
	x_spin_box.set_value_no_signal(Session.render_settings.resolution.x)
	y_spin_box.set_value_no_signal(Session.render_settings.resolution.y)
	
	fps_spin_box.set_value_no_signal(Session.render_settings.render_fps)
	
	color_quantization_checkbox.set_pressed_no_signal(Session.render_settings.use_color_quantization)
	_clear_palette()
	for color in Session.render_settings.quantization_palette:
		_add_color_to_palette_no_signal(color)
