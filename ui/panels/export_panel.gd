extends MarginContainer

@onready var export_path_edit: LineEdit = %ExportPath
@onready var spritesheet_columns_spinbox: SpinBox = %SpritesheetColumnsSpinbox
@onready var export_normals_checkbox: CheckBox = %ExportNormalsCheckbox


func _on_file_dialog_file_selected(path: String) -> void:
	if not path.ends_with(".png"):
		path = path + ".png"
	export_path_edit.text = path
	_build_export_settings()

func _build_export_settings():
	var settings = ExportSettings.new()
	settings.export_path = export_path_edit.text
	settings.spritesheet_columns = spritesheet_columns_spinbox.value
	settings.export_normals = export_normals_checkbox.button_pressed
	Session.set_export_settings(settings)

func _do_export():
	Exporter.export()
