extends MenuBar

@onready var file_menu: PopupMenu = %FileMenu
@onready var open_recent_menu: PopupMenu = %OpenRecentMenu
@onready var about_menu: PopupMenu = %AboutMenu

@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog

var recent_files_submenu: PopupMenu

func _ready():
	file_menu.add_item("New", 0)
	file_menu.set_item_shortcut(file_menu.get_item_index(0), _build_shortcut(KEY_N))
	
	file_menu.add_separator("", 1000)
	
	file_menu.add_item("Open...", 1)
	file_menu.set_item_shortcut(file_menu.get_item_index(1), _build_shortcut(KEY_O))
	
	file_menu.add_submenu_node_item("Open Recent", open_recent_menu, 2)
	
	file_menu.add_separator("", 1001)
	
	file_menu.add_item("Save", 3)
	file_menu.set_item_shortcut(file_menu.get_item_index(3), _build_shortcut(KEY_S))
	
	file_menu.add_item("Save As...", 4)
	file_menu.set_item_shortcut(file_menu.get_item_index(4), _build_shortcut(KEY_S, true, true))
	
	file_menu.add_separator("", 1002)
	
	file_menu.add_item("Exit", 5)
	file_menu.set_item_shortcut(file_menu.get_item_index(5), _build_shortcut(KEY_Q))
	
	about_menu.set_item_text(0, "%s v%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version")])
	
	_update_recent_files(RecentFileManager.recent_files)
	RecentFileManager.on_recent_files_updated.connect(_update_recent_files)

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0:
			# New
			Session.reset()
		1:
			# Open
			open_file_dialog.show()
		3:
			# Save
			if Session.currently_open_file != "":
				Session.save_flpx()
			else:
				save_file_dialog.show()
		4:
			# Save As
			save_file_dialog.show()
		5:
			# Exit
			get_tree().quit()

func _on_open_recent_menu_index_pressed(idx: int) -> void:
	# Clear recents
	if open_recent_menu.get_item_id(idx) == 1000:
		RecentFileManager.clear_recents()
	else:
		# Actually open something
		Session.load_flpx_file(open_recent_menu.get_item_text(idx))


func _on_open_path_selected(filepath: String):
	Session.load_flpx_file(filepath)

func _on_save_path_selected(filepath: String):
	Session.save_flpx(filepath)

func _update_recent_files(files: Array[String]):
	open_recent_menu.clear()
	if len(files) == 0:
		open_recent_menu.add_item("<empty>")
		open_recent_menu.set_item_disabled(0, true)
		return
	
	for recent in files:
		open_recent_menu.add_item(recent)
	open_recent_menu.add_separator()
	open_recent_menu.add_item("Clear Recents", 1000)

func _build_shortcut(key: Key, use_ctrl: bool = true, use_shift: bool = false) -> Shortcut:
	var shortcut := Shortcut.new()
	var event := InputEventKey.new()
	event.keycode = key
	event.ctrl_pressed = use_ctrl
	event.shift_pressed = use_shift
	shortcut.events = [event]
	return shortcut
