extends Node

signal changed(key: StringName, value: Variant)

const FILE_PATH: String = "user://settings.cfg"

var _values: Dictionary = {}
var _schema: Dictionary = {}

		
		

func _ready() -> void:
	_load_file()
	

func get_value(key: StringName, default: Variant = null) -> Variant:
	return _values.get(key, default)

func _set_value(key: StringName, value: Variant) -> void:
	if _schema.has(key) or _values.has(key):
		_values[key] = value
		emit_signal("changed", key, value)
		_save_file()
	else:
		push_error("Unknown setting key: %s" % key)

func _get(property: StringName) -> Variant:
	if property in _values:
		return _values[property]
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property in _schema:
		_values[property] = value
		emit_signal("changed", property, value)
		_save_file()
		return true
	return false

func _load_file() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err = cfg.load(FILE_PATH)
	if err != OK:
		return
	if cfg.has_section("settings"):
		for k in cfg.get_section_keys("settings"):
			_values[k] = cfg.get_value("settings", k)

func _save_file() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("settings", "___marker", true)
	for k in _values.keys():
		cfg.set_value("settings", k, _values[k])
	cfg.erase_section_key("settings", "___marker")
	cfg.save(FILE_PATH)