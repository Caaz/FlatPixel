class_name Exporter

static func export():
	if Session.most_recent_render == null:
		await Session.run_render()
	
	var render_result = Session.most_recent_render
	var export_path = Session.export_settings.export_path
	
	_write_frames_to_path(render_result.diffuse_frames, export_path)
	if Session.export_settings.export_normals:
		_write_frames_to_path(render_result.normal_frames, _build_normals_export_path(export_path))

static func _write_frames_to_path(frames: Array[Image], path: String):
	var merged := SpritesheetRenderer.merge_frames(frames)
	merged.save_png(path)

static func _build_normals_export_path(diffuse_path: String):
	var start = diffuse_path.trim_suffix(".png")
	return start + "-normal.png"
