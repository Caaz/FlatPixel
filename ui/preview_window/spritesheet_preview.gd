extends MarginContainer

@onready var frame_container: Container = %FrameContainer
@onready var type_select_option_button: OptionButton = %TypeSelectOptionButton

func _ready():
	Session.on_render.connect(_draw_render_preview)

func _use_diffuse() -> bool:
	return type_select_option_button.selected == 0

func _draw_render_preview():
	var render_result = Session.most_recent_render
	if render_result == null:
		_cleanup_preview()
	else:
		_create_frame_previews(render_result.diffuse_frames if _use_diffuse() else render_result.normal_frames)

func _cleanup_preview():
	for frame in frame_container.get_children():
		frame.queue_free()

func _create_frame_previews(frames: Array[Image]):
	_cleanup_preview()
	for frame in frames:
		var tex = ImageTexture.create_from_image(frame)
		var tex_rect = TextureRect.new()
		tex_rect.texture = tex
		frame_container.add_child(tex_rect)
