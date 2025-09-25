extends Node

const SAVE_PATH := "user://settings.cfg"

var _settings: Array[Setting] = []:
	set(value):
		_settings = value
		# Initialize values from defaults if missing.
		for s in _settings:
			if s.value == null:
				s.value = s.default_value
		emit_signal("settings_changed")
	get:
		return _settings
		

signal settings_changed

var _loaded_values: Dictionary = {}
var _loaded_applied := false

func _ready() -> void:
	# Save on any change, and try to apply loaded values the first time settings are provided.
	for s in _settings:
		print(" - %s: %s" % [s.name, s.value])
	settings_changed.connect(_on_settings_changed)
	_load_saved_values()
	_apply_loaded_values_if_any()
	# print all setting values
	print("Current settings:")
	for s in _settings:
		print(" - %s: %s" % [s.name, s.value])
	settings_changed.emit()

func _find_setting(property: StringName) -> Setting:
	for s in _settings:
		if s.name == String(property):
			return s
	return null

func has(property: StringName) -> bool:
	var s := _find_setting(property)
	return s != null and s.value != null

func _get(property: StringName) -> Variant:
	var s := _find_setting(property)
	return s.value if s != null else null

func _set(property: StringName, value: Variant) -> bool:
	var s := _find_setting(property)
	if s == null:
		push_error("Tried to set unknown setting: %s" % property)
		return false
	s.value = value
	emit_signal("settings_changed")
	return true

func _on_settings_changed() -> void:
	if not _loaded_applied:
		_apply_loaded_values_if_any()
	_save_settings()

func _apply_loaded_values_if_any() -> void:
	
	if _loaded_applied or _settings.is_empty():
		return
	print("Applying loaded values...")
	for s in _settings:
		if _loaded_values.has(s.name):
			print("Setting '%s' from loaded value: %s" % [s.name, _loaded_values[s.name]])
			s.value = _loaded_values[s.name]
		elif s.value == null and s.default_value != null:
			print("Setting '%s' to default value: %s" % [s.name, s.default_value])
			s.value = s.default_value
	_loaded_applied = true

func _load_saved_values() -> void:
	print("Loading settings from: %s" % SAVE_PATH)
	_loaded_values.clear()
	var cf := ConfigFile.new()
	var err := cf.load(SAVE_PATH)
	if err != OK:
		print("No settings file found or failed to load (error: %s)" % err)
		return
	if cf.has_section("settings"):
		print("Found settings section, loading values...")
		for key in cf.get_section_keys("settings"):
			var value = cf.get_value("settings", key)
			_loaded_values[key] = value
			print("Loaded setting '%s': %s" % [key, value])
	else:
		print("No 'settings' section found in config file")

func _save_settings() -> void:
	print("Saving settings to: %s" % SAVE_PATH)
	var cf := ConfigFile.new()
	for s in _settings:
		if s.value != null:
			print("Saving setting '%s': %s" % [s.name, s.value])
			cf.set_value("settings", s.name, s.value)
	var err := cf.save(SAVE_PATH)
	if err != OK:
		push_error("Failed to save settings: %s" % err)
	else:
		print("Settings saved successfully")
