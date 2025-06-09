extends Node

signal on_model_updated
signal on_camera_settings_updated
signal on_render_settings_updated
signal on_export_settings_updated

signal on_render

@export var camera_settings: CameraSettings = CameraSettings.new()
@export var render_settings: RenderSettings = RenderSettings.new()
@export var model_settings: ModelSettings = ModelSettings.new()
@export var export_settings: ExportSettings = ExportSettings.new()

var most_recent_render: RenderResult

func load_model(filepath: String):
	var model = ModelManager.load_model(filepath)
	model_settings.model = model
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
