extends Node

var _settings: Array[Setting] = []:
	set(value):
		_settings = value
		# Initialize values from defaults if missing.
		for s in _settings:
			if s.value == null:
				s.value = s.default_value
		emit_signal("settings_changed")
		print("Settings autoload updated settings: %s" % _settings)
	get:
		return _settings

signal settings_changed

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

func _process(_delta: float) -> void:
	var parts: Array = []
	for s in _settings:
		parts.append("%s=%s" % [s.name, str(s.value)])
	print("Settings: { %s }" % ", ".join(parts))
