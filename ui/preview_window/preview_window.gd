extends Control

@onready var model_root = %ModelRoot
@onready var camera = %Camera3D

func set_model(node: Node3D):
	for n in model_root.get_children():
		n.queue_free()
	model_root.add_child(node)

func set_model_rotation(rot: float):
	model_root.rotation_degrees = rot

func set_camera_offset(x: float, y: float):
	camera.global_position = Vector3(x, y, 2)
