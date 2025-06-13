class_name SimulationWorld
extends Node3D

@onready var camera: Camera3D = %Camera3D
@onready var camera_rotation_axis: Node3D = %CameraRotationAxis
@onready var post_filter = %PostFilter
@onready var model_root = %ModelRoot

func set_model(node: Node3D):
	for n in model_root.get_children():
		n.queue_free()
	if node != null:
		model_root.add_child(node)

func set_camera_settings(settings: CameraSettings):
	model_root.rotation_degrees = Vector3(0, settings.model_rotation, 0)
	camera.position = settings.camera_offset
	
	camera_rotation_axis.rotation_degrees = Vector3(settings.camera_tilt, 0, 0)
	
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL if settings.ortho_camera else Camera3D.PROJECTION_PERSPECTIVE
	camera.size = settings.ortho_camera_size
	camera.fov = settings.perspective_camera_fov

func set_render_settings(settings: RenderSettings):
	var post_shader = post_filter.get_active_material(0)
	
	var use_color_quantization = settings.use_color_quantization and settings.quantization_palette != null and len(settings.quantization_palette) > 0
	post_shader.set_shader_parameter("use_color_quantization", use_color_quantization)
	if use_color_quantization:
		var palette_image = PaletteHelper.build_palette_image(settings.quantization_palette)
		post_shader.set_shader_parameter("quantization_palette", ImageTexture.create_from_image(palette_image))

func set_normals(normals_enabled: bool):
	var post_shader = post_filter.get_active_material(0)
	post_shader.set_shader_parameter("use_normal", normals_enabled)
