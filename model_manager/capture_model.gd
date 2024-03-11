extends Node

var animation_player: AnimationPlayer

func _ready():
	for child in get_children():
		if child is AnimationPlayer:
			animation_player = child
			for animation in animation_player.get_animation_list():
				animation_player.get_animation(animation).loop_mode = Animation.LOOP_LINEAR
			print("Found animation player!")
			print("Available animations: %s" % animation_player.get_animation_list())

# Animation-related functions, for preview and final rendering
func get_available_animations() -> PackedStringArray:
	return animation_player.get_animation_list() if animation_player else PackedStringArray([])

func play_animation(animation: String):
	if not animation_player: return
	animation_player.play(animation)

func resume_animation():
	if not animation_player: return
	animation_player.play()

func pause_animation():
	if not animation_player: return
	animation_player.pause()

func set_animation_position(position: float):
	if not animation_player: return
	animation_player.seek(position, true)
