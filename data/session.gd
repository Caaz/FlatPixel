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

func load_model(filepath: String):
	var model = ModelManager.load_model(filepath)
	capture_model = model
	model_settings.model_path = filepath
	model_settings.selected_animations = []
	model_settings.available_animations = model.available_animations
	
	on_model_updated.emit()

func set_camera_settings(settings: CameraSettings):
	camera_settings = settings
	on_camera_settings_updated.emit()

func set_render_settings(settings: RenderSettings):
	render_settings = settings
	on_render_settings_updated.emit()

func set_export_settings(settings: ExportSettings):
	export_settings = settings
	on_export_settings_updated.emit()

func set_most_recent_render(render: RenderResult):
	most_recent_render = render
	on_render.emit()

func run_render():
	if SpritesheetRenderer.rendering:
		return
	set_most_recent_render(await SpritesheetRenderer.build_render())

func load_flpx_file(filepath: String):
	load_flpx(FlpxHandler.read_flpx_from_file(filepath))

func load_flpx(flpx: FlpxContents):
	load_model(flpx.model_settings.model_path)
	model_settings.selected_animations = flpx.model_settings.selected_animations
	
	set_camera_settings(flpx.camera_settings)
	set_render_settings(flpx.render_settings)
	set_export_settings(flpx.export_settings)
	
	on_flpx_loaded.emit()
