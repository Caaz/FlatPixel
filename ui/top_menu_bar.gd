extends MenuBar

@onready var file_menu: PopupMenu = %FileMenu
@onready var open_recent_menu: PopupMenu = %OpenRecentMenu
@onready var about_menu: PopupMenu = %AboutMenu

@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog

var recent_files_submenu: PopupMenu

enum MenuItem {NEW, OPEN, OPEN_RECENT, SAVE, SAVE_AS, EXIT}

func _ready():
	file_menu.add_item("New", MenuItem.NEW)
	file_menu.set_item_shortcut(file_menu.get_item_index(MenuItem.NEW), _build_shortcut(KEY_N))
	
	file_menu.add_separator("", 1000)
	
	file_menu.add_item("Open...", MenuItem.OPEN)
	file_menu.set_item_shortcut(file_menu.get_item_index(MenuItem.OPEN), _build_shortcut(KEY_O))
	
	file_menu.add_submenu_node_item("Open Recent", open_recent_menu, MenuItem.OPEN_RECENT)
	
	file_menu.add_separator("", 1001)
	
	file_menu.add_item("Save", MenuItem.SAVE)
	file_menu.set_item_shortcut(file_menu.get_item_index(MenuItem.SAVE), _build_shortcut(KEY_S))
	
	file_menu.add_item("Save As...", MenuItem.SAVE_AS)
	file_menu.set_item_shortcut(file_menu.get_item_index(MenuItem.SAVE_AS), _build_shortcut(KEY_S, true, true))
	
	file_menu.add_separator("", 1002)
	
	file_menu.add_item("Exit", MenuItem.EXIT)
	file_menu.set_item_shortcut(file_menu.get_item_index(MenuItem.EXIT), _build_shortcut(KEY_Q))
	
	about_menu.set_item_text(0, "%s v%s" % [ProjectSettings.get_setting("application/config/name"), ProjectSettings.get_setting("application/config/version")])
	
	_update_recent_files(RecentFileManager.recent_files)
	RecentFileManager.on_recent_files_updated.connect(_update_recent_files)

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		MenuItem.NEW:
			Session.reset()
		MenuItem.OPEN:
			# Open
			open_file_dialog.show()
		MenuItem.SAVE:
			# Save
			if Session.currently_open_file != "":
				Session.save_flpx()
			else:
				save_file_dialog.show()
		MenuItem.SAVE_AS:
			# Save As
			save_file_dialog.show()
		MenuItem.EXIT:
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
