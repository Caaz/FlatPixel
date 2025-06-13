extends Node

const RECENT_FILE_PATH: String = "user://recent_files.cfg"
const MAX_RECENT_FILES: int = 8

signal on_recent_files_updated(recent_files: Array[String])

var recent_files: Array[String]

func _ready() -> void:
	load_config_file()

func add_recent_file(filepath: String):
	if filepath == "":
		return
	
	# Prevent same file from appearing multiple times
	while filepath in recent_files:
		recent_files.erase(filepath)
	
	recent_files.push_front(filepath)
	if len(recent_files) > MAX_RECENT_FILES:
		recent_files = recent_files.slice(0, MAX_RECENT_FILES)
	save_config_file()
	on_recent_files_updated.emit(recent_files)

func load_config_file():
	var config = ConfigFile.new()
	var err = config.load(RECENT_FILE_PATH)
	if err != OK:
		return
	
	recent_files = config.get_value("recents", "files")

func save_config_file():
	var config = ConfigFile.new()
	config.set_value("recents", "files", recent_files)
	config.save(RECENT_FILE_PATH)
