class_name Exporter

static func export():
	if not is_instance_valid(Session.most_recent_render):
		await Session.run_render()
	
	var render_result = Session.most_recent_render
	var export_path = Session.export_settings.export_path
	var normals_export_path = _build_normals_export_path(export_path)
	
	_write_frames_to_path(render_result.diffuse_frames, export_path)
	if Session.export_settings.export_normals:
		_write_frames_to_path(render_result.normal_frames, normals_export_path)
	
	_write_render_report_json(export_path, normals_export_path, render_result)
	
	EventReporter.report_export(Session.export_settings.export_path)

static func _write_frames_to_path(frames: Array[Image], path: String):
	var merged := SpritesheetRenderer.merge_frames(frames)
	merged.save_png(path)

static func _build_normals_export_path(diffuse_path: String):
	var start = diffuse_path.trim_suffix(".png")
	return start + "-normal.png"

static func _build_json_export_path(diffuse_path: String):
	var start = diffuse_path.trim_suffix(".png")
	return start + ".json"

static func _write_render_report_json(diffuse_path: String, normals_path: String, render_result: RenderResult):
	var json = {}
	
	json["diffuse_path"] = diffuse_path
	if Session.export_settings.export_normals:
		json["normals_path"] = normals_path
	
	json["frame_resolution"] = {
		"x": render_result.render_resolution.x,
		"y": render_result.render_resolution.y
	}
	
	json["animation_fps"] = render_result.render_fps
	
	var anim_details = []
	for elem in render_result.animation_details:
		anim_details.append({
			"animation": elem.animation_name,
			"frame_start": elem.frame_start,
			"frame_end": elem.frame_end
		})
	json["animation_details"] = anim_details
	
	var json_string = JSON.stringify(json, "\t")
	
	var output_path = _build_json_export_path(diffuse_path)
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
