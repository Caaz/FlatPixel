class_name FlpxHandler

const FLPX_EXTENSION: String = ".flpx"

static func get_session_flpx() -> FlpxContents:
	var flpx = FlpxContents.new()
	flpx.camera_settings = Session.camera_settings.duplicate()
	flpx.model_settings = Session.model_settings.duplicate()
	flpx.render_settings = Session.render_settings.duplicate()
	flpx.export_settings = Session.export_settings.duplicate()
	
	return flpx

static func get_session_flpx_string() -> String:
	return JSON.stringify(_flpx_to_dict(get_session_flpx()), "\t")

static func get_flpx_from_string(contents: String) -> FlpxContents:
	var dict = JSON.parse_string(contents)
	return _dict_to_flpx(dict)


static func _flpx_to_dict(flpx: FlpxContents) -> Dictionary:
	return {
		"model": {
			"model_path": flpx.model_settings.model_path,
			"available_animations": flpx.model_settings.available_animations,
			"selected_animations": flpx.model_settings.selected_animations
		},
		"camera": {
			"model_rotation": flpx.camera_settings.model_rotation,
			"camera_offset": var_to_str(flpx.camera_settings.camera_offset),
			"camera_tilt": flpx.camera_settings.camera_tilt,
			"ortho_camera": flpx.camera_settings.ortho_camera,
			"ortho_camera_size": flpx.camera_settings.ortho_camera_size,
			"perspective_camera_fov": flpx.camera_settings.perspective_camera_fov,
			"turntable_steps": flpx.camera_settings.turntable_steps
		},
		"render": {
			"resolution": var_to_str(flpx.render_settings.resolution),
			"use_color_quantization": flpx.render_settings.use_color_quantization,
			"quantization_palette": Array(flpx.render_settings.quantization_palette).map(func (c: Color): return var_to_str(c)),
			"render_fps": flpx.render_settings.render_fps
		},
		"export": {
			"export_path": flpx.export_settings.export_path,
			"spritesheet_columns": flpx.export_settings.spritesheet_columns,
			"export_normals": flpx.export_settings.export_normals
		}
	}

static func _dict_to_flpx(dict: Dictionary) -> FlpxContents:
	var flpx = FlpxContents.new()
	
	var model_dict = dict.get("model", {})
	var camera_dict = dict.get("camera", {})
	var render_dict = dict.get("render", {})
	var export_dict = dict.get("export", {})
	
	if model_dict.has("model_path"):
		flpx.model_settings.model_path = model_dict["model_path"]
	if model_dict.has("available_animations"):
		flpx.model_settings.available_animations = model_dict["available_animations"]
	if model_dict.has("selected_animations"):
		flpx.model_settings.selected_animations = model_dict["selected_animations"]
	
	if camera_dict.has("model_rotation"):
		flpx.camera_settings.model_rotation = camera_dict["model_rotation"]
	if camera_dict.has("camera_offset"):
		flpx.camera_settings.camera_offset = str_to_var(camera_dict["camera_offset"])
	if camera_dict.has("camera_tilt"):
		flpx.camera_settings.camera_tilt = camera_dict["camera_tilt"]
	if camera_dict.has("ortho_camera"):
		flpx.camera_settings.ortho_camera = camera_dict["ortho_camera"]
	if camera_dict.has("ortho_camera_size"):
		flpx.camera_settings.ortho_camera_size = camera_dict["ortho_camera_size"]
	if camera_dict.has("perspective_camera_fov"):
		flpx.camera_settings.perspective_camera_fov = camera_dict["perspective_camera_fov"]
	if camera_dict.has("turntable_steps"):
		flpx.camera_settings.turntable_steps = camera_dict["turntable_steps"]
	
	if render_dict.has("resolution"):
		flpx.render_settings.resolution = str_to_var(render_dict["resolution"])
	if render_dict.has("use_color_quantization"):
		flpx.render_settings.use_color_quantization = render_dict["use_color_quantization"]
	if render_dict.has("quantization_palette"):
		flpx.render_settings.quantization_palette = (render_dict["quantization_palette"].map(func (c): return str_to_var(c)))
	if render_dict.has("render_fps"):
		flpx.render_settings.render_fps = render_dict["render_fps"]
	
	if export_dict.has("export_path"):
		flpx.export_settings.export_path = export_dict["export_path"]
	if export_dict.has("spritesheet_columns"):
		flpx.export_settings.spritesheet_columns = export_dict["spritesheet_columns"]
	if export_dict.has("export_normals"):
		flpx.export_settings.export_normals = export_dict["export_normals"]
	
	return flpx


static func _get_dict_value(dict: Dictionary, subdict: String, key: String, default: Variant = null):
	var nested_dict = dict.get(subdict, {})
	return nested_dict.get(key, default)


static func save_session_flpx(path: String):
	if not path.ends_with(FLPX_EXTENSION):
		path = path + FLPX_EXTENSION
	
	var session_flpx_data = get_session_flpx_string()
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(session_flpx_data)
	file.close()

static func read_flpx_from_file(path: String) -> FlpxContents:
	var file = FileAccess.open(path, FileAccess.READ)
	var flpx_string = file.get_as_text()
	return get_flpx_from_string(flpx_string)
