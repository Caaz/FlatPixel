class_name SimulationWorld
extends Node3D

@onready var camera = %Camera3D
@onready var post_filter = %PostFilter
@onready var model_root = %ModelRoot

func set_model(node: Node3D):
	for n in model_root.get_children():
		remove_child(n)
	if node != null:
		model_root.add_child(node)

func set_camera_settings(settings: CameraSettings):
	model_root.rotation_degrees = Vector3(0, settings.model_rotation, 0)
	camera.global_position = settings.camera_offset
	camera.rotation_degrees = Vector3(settings.camera_tilt, 0, 0)

func set_render_settings(settings: RenderSettings):
	post_filter.get_active_material(0).set_shader_parameter("use_normal", settings.render_normal_map)
