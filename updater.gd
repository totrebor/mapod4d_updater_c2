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
	'v4': 0
}
const M4DNAME = "updater"

const WK_PATH = 'wk'
const UPDATES_PATH = WK_PATH + '/updates/'
const UPDATER = "updater"
const UPDATER_PATH = WK_PATH + "/" + UPDATER
const MULTIVSVR = "https://sv001.mapod4d.it"

# ----- exported variables

# ----- public variables

# ----- private variables
var _base_path = null
var _exe_ext = ""

# ----- onready variables
@onready var timer = $Timer


# ----- optional built-in virtual _init method

# ----- built-in virtual _ready method

# Called when the node enters the scene tree for the first time.
func _ready():
	match OS.get_name():
		"Windows", "UWP":
			_exe_ext = ".exe"
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
	var updater_ready = false
	if OS.has_feature('editor'):
		_base_path = 'test/wk'
	if OS.has_feature('standalone'):
		_base_path = OS.get_executable_path().get_base_dir()
	# print(_base_path)
	var slice_list = _base_path.split("/")
	if slice_list.size() > 1:
		# print(slice_list)
		slice_list.remove_at(slice_list.size()-1)
		_base_path = "/".join(slice_list)
		# print(_base_path)
		var args = OS.get_cmdline_user_args()
		if args.size() > 0:
			if args[0] == "-m4dupdate":
				updater_ready = true
		if updater_ready == true:
			# print("UPDATE")
			await get_tree().create_timer(1).timeout
			_update_launcher()
		else:
			get_tree().quit()
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


func _update_launcher():
	if _base_path != null:
		var dir = DirAccess.open(_base_path)
		if dir != null:
			var dw_launcher_path = UPDATES_PATH + "launcher"
			# print(dw_launcher_path)
			if dir.file_exists(dw_launcher_path):
				var from_file_name = dw_launcher_path
				var to_file_name = "mapod4d_launcher" + _exe_ext
				var _error = dir.rename(from_file_name, to_file_name)
				# print(_error)
		else:
			print("%s not found" % _base_path)

	timer.timeout.connect(_timer_timeout)
	timer.start()


func _timer_timeout():
	get_tree().quit()

