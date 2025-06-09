class_name FlpxHandler

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
			"perspective_camera_fov": flpx.camera_settings.perspective_camera_fov
		},
		"render": {
			"resolution": var_to_str(flpx.render_settings.resolution),
			"use_color_quantization": flpx.render_settings.use_color_quantization,
			"quantization_palette": Array(flpx.render_settings.quantization_palette).map(func (c: Color): return var_to_str(c)),
			"render_fps": flpx.render_settings.render_fps
		},
		"export": {
			"export_path": flpx.export_settings.export_path,
			"export_normals": flpx.export_settings.export_normals
		}
	}

static func _dict_to_flpx(dict: Dictionary) -> FlpxContents:
	var flpx = FlpxContents.new()
	
	flpx.model_settings.model_path = dict["model"]["model_path"]
	flpx.model_settings.available_animations = dict["model"]["available_animations"]
	flpx.model_settings.selected_animations = dict["model"]["selected_animations"]
	
	flpx.camera_settings.model_rotation = dict["camera"]["model_rotation"]
	flpx.camera_settings.camera_offset = str_to_var(dict["camera"]["camera_offset"])
	flpx.camera_settings.camera_tilt = dict["camera"]["camera_tilt"]
	flpx.camera_settings.ortho_camera = dict["camera"]["ortho_camera"]
	flpx.camera_settings.ortho_camera_size = dict["camera"]["ortho_camera_size"]
	flpx.camera_settings.perspective_camera_fov = dict["camera"]["perspective_camera_fov"]
	
	flpx.render_settings.resolution = str_to_var(dict["render"]["resolution"])
	flpx.render_settings.use_color_quantization = dict["render"]["use_color_quantization"]
	flpx.render_settings.quantization_palette = (dict["render"]["quantization_palette"].map(func (c): return str_to_var(c)))
	flpx.render_settings.render_fps = dict["render"]["render_fps"]
	
	flpx.export_settings.export_path = dict["export"]["export_path"]
	flpx.export_settings.export_normals = dict["export"]["export_normals"]
	
	return flpx
