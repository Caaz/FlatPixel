class_name CaptureModel
extends Node3D

var animation_player: AnimationPlayer
var available_animations: PackedStringArray

func _ready():
	preprocess_animations()
	for child in get_children():
		if child is AnimationPlayer:
			animation_player = child

func preprocess_animations():
	for child in get_children():
		if child is AnimationPlayer:
			var player := child as AnimationPlayer
			for animation in player.get_animation_list():
				player.get_animation(animation).loop_mode = Animation.LOOP_LINEAR
			available_animations = player.get_animation_list()

func play_animation(animation: String):
	if not animation_player: return
	animation_player.play(animation)

func resume_animation():
	if not animation_player: return
	animation_player.play()

func pause_animation():
	if not animation_player: return
	animation_player.pause()

func set_animation_position(frame_position: float):
	if not animation_player: return
	animation_player.seek(frame_position, true)

func get_aabb():
	return _calculate_spatial_bounds(self)

func _calculate_spatial_bounds(parent : Node3D, exclude_top_level_transform: bool = true) -> AABB:
	var bounds : AABB = AABB()
	if parent is VisualInstance3D:
		bounds = parent.get_aabb();

	for i in range(parent.get_child_count()):
		var child = parent.get_child(i)
		if child and child is Node3D:
			var child_bounds : AABB = _calculate_spatial_bounds(child, false)
			if bounds.size == Vector3.ZERO && parent:
				bounds = child_bounds
			else:
				bounds = bounds.merge(child_bounds)
	if bounds.size == Vector3.ZERO && !parent:
		bounds = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
	if !exclude_top_level_transform:
		bounds = parent.transform * bounds
	return bounds
