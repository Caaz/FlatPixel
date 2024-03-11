extends Control

signal file_selected(path: String)

func _on_file_dialog_file_selected(path):
	file_selected.emit(path)
