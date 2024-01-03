# tool

# class_name

# extends
extends Control

## A brief description of your script.
##
## A more detailed description of the script.
##
## @tutorial:			http://the/tutorial1/url.com
## @tutorial(Tutorial2): http://the/tutorial2/url.com


# ----- signals

# ----- enums

# ----- constants
const M4DVERSION = {
	'v1': 2,
	'v2': 0,
	'v3': 0,
	'v4': 3,
	'p': "a",
	'godot': {
		'v1': 4,
		'v2': 2,
		'v3': 1,
		'v4': 2, # dev = 0, rc = 1, stable = 2
		'p': "stable"
	}
}
const M4DNAME = "updater"

const WK_PATH = 'wk'
const UPDATES_DIR = "updates"
const TMP_DIR = "tmp"

## name of software updater on the update server
const UPDATER_NAME = "updater"
## name of software updater
const UPDATER_EXE_NAME = "updater"
## storage name for data info of software updater
const UPDATER_INFO = "updater_info"
## name of software launcher on the update server
const LAUNCHER_NAME = "launcherm"
## name of software launcher
const LAUNCHER_EXE_NAME = "mapod4d"
## storage name for data info of software launcher
const LAUNCHER_INFO = "launcherm_info"
## name of software core on the update server
const CORE_NAME = "core"
## name of software core
const CORE_EXE_NAME = "core"

const EDITOR_DBG_BASE_PATH = "res://test"

#const UPDATES_PATH = WK_PATH + '/updates'
#const UPDATER = "updater"
#const LAUNCHER = "mapod4d"
#const UPDATER_PATH = WK_PATH + "/" + UPDATER
#const MULTIVSVR = "https://sv001.mapod4d.it"


# ----- exported variables

# ----- public variables

# ----- private variables
var _base_path = null
var _ext = ""

## dinamic paths 
var _build_updater_path = null
var _build_launcher_path = null
var _build_core_path = null
var _build_wk_path = null
var _build_updates_path = null
var _build_tmp_dir = null
var _build_dest_dw_path = null

# ----- onready variables
@onready var timer = $Timer


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	match OS.get_name():
		"Windows", "UWP":
			_ext = ".exe"
		"macOS":
			pass
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			pass
		"Android":
			pass
		"iOS":
			pass
		"Web":
			pass
	var updater_ready = _verify_starting_condiction()

	if updater_ready == true:
		_do_launcher_update()
	else:
		get_tree().quit()


# ----- remaining built-in virtual methods
func _enter_tree():
	var args = OS.get_cmdline_user_args()
	# print(args)
	if "-m4dver" in args:
		_write_version()
		get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass # Replace with function body.

# ----- public methods

# ----- private methods
## verify ready condictions
func _verify_starting_condiction():
	var ret_val = true

	if OS.has_feature('editor'):
		_base_path = EDITOR_DBG_BASE_PATH
	elif OS.has_feature('standalone'):
		_base_path = OS.get_executable_path().get_base_dir()
	else:
		## error message
		ret_val = false
	
	printerr(_base_path)
	
	if ret_val == true:
		# adjust base path
		var split_base_path = _base_path.split("/")
		var last_element = split_base_path.size() - 1
		split_base_path.remove_at(last_element)
		var tmp_base_path = ""
		for element in split_base_path:
			tmp_base_path += element + "/"
		if tmp_base_path != "res://":
			tmp_base_path = tmp_base_path.rstrip("/")
		_base_path = tmp_base_path
		
		## build dinamic paths
		_build_wk_path = "%s/%s" % [_base_path, WK_PATH] 
		_build_updater_path = "%s/%s" % [_build_wk_path , UPDATER_EXE_NAME]
		_build_launcher_path = "%s/%s" % [_base_path , LAUNCHER_EXE_NAME]
		_build_updates_path = "%s/%s" % [_build_wk_path , UPDATES_DIR]
		_build_tmp_dir = "%s/%s" % [_build_wk_path , TMP_DIR]
		_build_dest_dw_path = "%s/dw_" % [_build_updates_path]

		#if ret_val == true:
			#var slice_list = _base_path.split("/")
			#if slice_list.size() > 1:
				#slice_list.remove_at(slice_list.size()-1)
				#_base_path = "/".join(slice_list)
				## print(_base_path)
			#else:
				### error message
				#ret_val = false

		var args = OS.get_cmdline_user_args()
		if args.size() > 0:
			if args[0] != "-m4dupdate":
				## error message
				ret_val = false

	return ret_val



func _write_version():
		# print(M4DVERSION)
		var json_data = JSON.stringify(M4DVERSION)
		var base_dir = OS.get_executable_path().get_base_dir()
		if OS.has_feature('editor'):
			base_dir = "test"
		var file_name = base_dir + "/" + M4DNAME + ".json"
		# print(file_name)
		var file = FileAccess.open(file_name, FileAccess.WRITE)
		if file != null:
			file.store_string(json_data)
			file.flush()


func _do_launcher_update():
	if _base_path != null:
		var dir = DirAccess.open(_base_path)
		if dir != null:
			printerr("sssss")
			printerr(_build_dest_dw_path)
			printerr(LAUNCHER_EXE_NAME)
			printerr("sssss1")
			var dw_launcher_path = \
					"%s%s.bin" % [_build_dest_dw_path, LAUNCHER_EXE_NAME]
			printerr(dw_launcher_path)
			if dir.file_exists(dw_launcher_path):
				var from_file_name = dw_launcher_path
				var to_file_name = _build_launcher_path + str(_ext)
				printerr(from_file_name)
				printerr(to_file_name)
				var _error = dir.rename(from_file_name, to_file_name)
				if OS.has_feature('editor') == false:
					if dir.file_exists(to_file_name):
						OS.create_process(to_file_name, [])
						get_tree().quit()
		else:
			printerr("%s not found" % _base_path)

	timer.timeout.connect(_timer_timeout)
	timer.start()


func _timer_timeout():
	get_tree().quit()

