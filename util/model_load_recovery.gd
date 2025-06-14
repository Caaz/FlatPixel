extends Node

const CONFIRMATION_DIALOG_FORMAT: String = "Failed to load model at \"%s\". Please relocate model."

@onready var open_model_dialog: FileDialog = $OpenModelDialog
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog


func _ready() -> void:
	Session.on_model_load_failure.connect(_kickoff_recovery)

func _kickoff_recovery(path: String):
	confirmation_dialog.dialog_text = CONFIRMATION_DIALOG_FORMAT % path
	confirmation_dialog.show()

func _recover_model(path: String):
	Session.load_model(path)
