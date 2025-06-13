extends Control

@onready var file_menu: PopupMenu = %FileMenu
@onready var about_menu: PopupMenu = %AboutMenu

func _ready():
	about_menu.set_item_text(0, "%s v%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version")])


func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0:
			print("New")
		2:
			print("Open")
		3:
			print("Save")
		4:
			print("Save As")
		6:
			get_tree().quit()
