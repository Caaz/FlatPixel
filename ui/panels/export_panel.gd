extends MarginContainer

const OVERWRITE_FORMAT = "File %s already exists. Overwrite with export?"

@onready var export_path_edit: LineEdit = %ExportPath
@onready var spritesheet_columns_spinbox: SpinBox = %SpritesheetColumnsSpinbox
@onready var export_normals_checkbox: CheckBox = %ExportNormalsCheckbox

@onready var export_path_select_file_dialog: FileDialog = %FileDialog
@onready var confirm_export_overwrite_dialog: ConfirmationDialog = %ConfirmExportOverwriteDialog

func _ready():
	Session.on_flpx_loaded.connect(_on_flpx_loaded)
	_build_export_settings.call_deferred()

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
	if Session.export_settings.export_path == "":
		_open_export_path_dialog()
	else:
		if FileAccess.file_exists(Session.export_settings.export_path):
			confirm_export_overwrite_dialog.dialog_text = OVERWRITE_FORMAT % Session.export_settings.export_path
			confirm_export_overwrite_dialog.show()
		else:
			Exporter.export()

func _confirm_export():
	Exporter.export()

func _open_export_path_dialog():
	if Session.export_settings.export_path != "":
		export_path_select_file_dialog.current_file = Session.export_settings.export_path
	export_path_select_file_dialog.show()

func _on_flpx_loaded():
	export_path_edit.text = Session.export_settings.export_path
	spritesheet_columns_spinbox.set_value_no_signal(Session.export_settings.spritesheet_columns)
	export_normals_checkbox.set_pressed_no_signal(Session.export_settings.export_normals)
