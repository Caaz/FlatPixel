extends Node

signal on_model_updated
signal on_camera_settings_updated
signal on_render_settings_updated
signal on_export_settings_updated

signal on_flpx_loaded

signal on_render

@export var camera_settings: CameraSettings = CameraSettings.new()
@export var render_settings: RenderSettings = RenderSettings.new()
@export var model_settings: ModelSettings = ModelSettings.new()
@export var export_settings: ExportSettings = ExportSettings.new()

var capture_model: CaptureModel
var most_recent_render: RenderResult

var session_dirty: bool = false :
	set(value):
		session_dirty = value
		_reset_window_title()

var currently_open_file: String :
	set(value):
		currently_open_file = value
		RecentFileManager.add_recent_file(currently_open_file)
		_reset_window_title()

func load_model(filepath: String):
	if filepath == "":
		capture_model = null
		model_settings.model_path = ""
		model_settings.selected_animations = []
		model_settings.available_animations = []
	else:
		var model = ModelManager.load_model(filepath)
		capture_model = model
		model_settings.model_path = filepath
		model_settings.selected_animations = []
		model_settings.available_animations = model.available_animations
	
	session_dirty = true
	on_model_updated.emit()

func set_camera_settings(settings: CameraSettings):
	camera_settings = settings
	session_dirty = true
	on_camera_settings_updated.emit()

func set_render_settings(settings: RenderSettings):
	render_settings = settings
	session_dirty = true
	on_render_settings_updated.emit()

func set_export_settings(settings: ExportSettings):
	export_settings = settings
	session_dirty = true
	on_export_settings_updated.emit()

func set_most_recent_render(render: RenderResult):
	most_recent_render = render
	EventReporter.report_render(render)
	on_render.emit()

func run_render():
	if SpritesheetRenderer.rendering:
		return
	set_most_recent_render(await SpritesheetRenderer.build_render())

func load_flpx_file(filepath: String):
	load_flpx(FlpxHandler.read_flpx_from_file(filepath))
	currently_open_file = filepath
	EventReporter.report_open(filepath)

func load_flpx(flpx: FlpxContents):
	load_model(flpx.model_settings.model_path)
	model_settings.selected_animations = flpx.model_settings.selected_animations
	
	set_camera_settings(flpx.camera_settings)
	set_render_settings(flpx.render_settings)
	set_export_settings(flpx.export_settings)
	
	session_dirty = false
	on_flpx_loaded.emit()

func save_flpx(path: String = ""):
	if path != "":
		currently_open_file = path
	
	if not path.ends_with(".flpx"):
		path = path + ".flpx"
	
	if currently_open_file == "":
		push_error("Cannot save file when no file handle has been provided!")
	
	FlpxHandler.save_session_flpx(currently_open_file)
	session_dirty = false
	EventReporter.report_save(path)

func reset():
	load_flpx(FlpxContents.new())
	currently_open_file = ""
	session_dirty = false

func _reset_window_title():
	var title = "FlatPixel - %s" % currently_open_file.split("/")[-1]
	if session_dirty:
		title += "*"
	get_window().title = title
