class_name EventBar
extends PanelContainer

@onready var label: Label = $Label

func _ready():
	EventReporter.on_event_reported.connect(_update_text)

func _update_text(text: String):
	label.text = text
