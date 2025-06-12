class_name RenderProgressPopup
extends Control

@onready var label: Label = %Label
@onready var progress_bar: ProgressBar = %ProgressBar

func _ready():
	SpritesheetRenderer.on_render_start.connect(popup)
	SpritesheetRenderer.on_render_finish.connect(unpopup)
	SpritesheetRenderer.on_render_progress_update.connect(update_percentage)

func popup(render_title: String):
	label.text = "Rendering... (%s)" % render_title
	progress_bar.value = 0
	visible = true

func unpopup():
	visible = false

func update_percentage(current_frame: int, total_frames: int, current_animation: int, total_animations: int):
	var percentage = _calculate_percentage(current_frame, total_frames, current_animation, total_animations)
	progress_bar.value = percentage

func _calculate_percentage(current_frame: int, total_frames: int, current_animation: int, total_animations: int):
	var progress_per_animation = 100.0 / total_animations
	var progress_per_frame = progress_per_animation / total_frames
	return (current_animation * progress_per_animation) + ((current_frame + 1) * progress_per_frame)
