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
