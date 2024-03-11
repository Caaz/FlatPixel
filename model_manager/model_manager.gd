extends Node

var gltf_document: GLTFDocument
var gltf_state: GLTFState

var model_scene: Node3D

func load_model(path: String):
	gltf_document = GLTFDocument.new()
	gltf_state = GLTFState.new()
	var error = gltf_document.append_from_file(path, gltf_state)
	if error != OK:
		push_error("Failed to load gltf at %s" % path)
		
	var gltf_scene_root_node = gltf_document.generate_scene(gltf_state)
	model_scene = _preprocess_model(gltf_scene_root_node)
	
	return model_scene

func _preprocess_model(node: Node):
	# Recursive descent processing
	for child in node.get_children():
		_preprocess_model(child)
	
	if node is MeshInstance3D:
		for i in range(node.mesh.get_surface_count()):
			var temp_mat: BaseMaterial3D = node.mesh.surface_get_material(i).duplicate(true) as BaseMaterial3D
			temp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			node.set_surface_override_material(i, temp_mat)
	
	node.set_script(preload("res://model_manager/capture_model.gd"))
	
	return node

func set_model_animation(animation: String):
	model_scene.play_animation(animation)

func play_model_animation():
	model_scene.resume_animation()

func pause_model_animation():
	model_scene.pause_animation()
