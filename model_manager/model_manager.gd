class_name ModelManager

static func load_model(path: String) -> CaptureModel:
	var gltf_document := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	if not FileAccess.file_exists(path):
		return null
	var error := gltf_document.append_from_file(path, gltf_state)
	if error != OK:
		return null
		
	var gltf_scene_root_node := gltf_document.generate_scene(gltf_state)
	var model_scene := _preprocess_model(gltf_scene_root_node)
	
	return model_scene as CaptureModel

static func _preprocess_model(node: Node) -> CaptureModel:
	_preprocess_step(node)
	node.set_script(preload("res://model_manager/capture_model.gd"))
	var capture_model := node as CaptureModel
	capture_model.preprocess_animations()
	return capture_model

static func _preprocess_step(node: Node):
	# Recursive descent processing
	for child in node.get_children():
		_preprocess_step(child)
	
	if node is MeshInstance3D:
		for i in range((node as MeshInstance3D).mesh.get_surface_count()):
			var temp_mat: BaseMaterial3D = node.mesh.surface_get_material(i).duplicate(true) as BaseMaterial3D
			temp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			node.set_surface_override_material(i, temp_mat)
