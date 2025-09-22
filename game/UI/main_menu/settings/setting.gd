@tool
extends Resource
class_name Setting


@export var name: String
@export_enum("bool", "int", "float", "string", "color") var type: String:
	get:
		return _type
	set(value):
		_type = value
		_set_thing()

var _type: String = "bool"
# Stop exporting as raw Variant; we will expose it dynamically with a concrete type.
var default_value: Variant = null
var value: Variant = null

# Optional limits (only used for int/float via dynamic property list).
var _use_limits: bool = false
var use_limits: bool:
	get: return _use_limits
	set(value):
		_use_limits = value
		notify_property_list_changed()
		_clamp_default_if_needed()
		_clamp_value_if_needed()

var _lower_limit: float = 0.0
var lower_limit: float:
	get: return _lower_limit
	set(value):
		_lower_limit = value
		if _use_limits and _lower_limit > _upper_limit:
			_upper_limit = _lower_limit
		_clamp_default_if_needed()
		_clamp_value_if_needed()

var _upper_limit: float = 1.0
var upper_limit: float:
	get: return _upper_limit
	set(value):
		_upper_limit = value
		if _use_limits and _upper_limit < _lower_limit:
			_lower_limit = _upper_limit
		_clamp_default_if_needed()
		_clamp_value_if_needed()

# Expose default_value with the correct typed editor in the Inspector.
func _get_property_list() -> Array:
	var t := TYPE_NIL
	match _type:
		"bool":
			t = TYPE_BOOL
		"int":
			t = TYPE_INT
		"float":
			t = TYPE_FLOAT
		"string":
			t = TYPE_STRING
		"color":
			t = TYPE_COLOR
		_:
			t = TYPE_NIL

	var list: Array = []

	# Default value descriptor (with optional range hint for numeric types).
	var default_desc := {
		"name": "default_value",
		"type": t,
		"usage": PROPERTY_USAGE_DEFAULT,
	}
	if _type == "int" or _type == "float":
		if _use_limits:
			default_desc["hint"] = PROPERTY_HINT_RANGE
			if _type == "int":
				default_desc["hint_string"] = "%d,%d,1" % [int(_lower_limit), int(_upper_limit)]
			else:
				# Step left out intentionally; users can still type arbitrary precision.
				default_desc["hint_string"] = "%s,%s" % [str(_lower_limit), str(_upper_limit)]
	list.append(default_desc)

	# Current value descriptor (mirrors typing and range hints).
	var value_desc := {
		"name": "value",
		"type": t,
		"usage": PROPERTY_USAGE_DEFAULT,
	}
	if _type == "int" or _type == "float":
		if _use_limits:
			value_desc["hint"] = PROPERTY_HINT_RANGE
			if _type == "int":
				value_desc["hint_string"] = "%d,%d,1" % [int(_lower_limit), int(_upper_limit)]
			else:
				value_desc["hint_string"] = "%s,%s" % [str(_lower_limit), str(_upper_limit)]
	list.append(value_desc)

	# Limits controls only for numeric types.
	if _type == "int" or _type == "float":
		list.append({
			"name": "use_limits",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
		var num_t := TYPE_INT if _type == "int" else TYPE_FLOAT
		var limits_usage := PROPERTY_USAGE_DEFAULT if _use_limits else PROPERTY_USAGE_NO_EDITOR
		list.append({
			"name": "lower_limit",
			"type": num_t,
			"usage": limits_usage,
		})
		list.append({
			"name": "upper_limit",
			"type": num_t,
			"usage": limits_usage,
		})

	return list

func _set_thing() -> void:
	print("Setting type changed to ", _type)
	if default_value == null:
		match _type:
			"bool":
				default_value = false
			"int":
				default_value = 0
			"float":
				default_value = 0.0
			"string":
				default_value = ""
			"color":
				default_value = Color.AQUA
			_:
				push_error("Unknown setting type: %s" % _type)
	# Ensure value exists and matches the new type default when missing.
	if value == null:
		value = default_value
	# Refresh the inspector so editors match the new type.
	notify_property_list_changed()
	_clamp_default_if_needed()
	_clamp_value_if_needed()
	print("Default value set to ", default_value)

func _clamp_default_if_needed() -> void:
	if not _use_limits or default_value == null:
		return
	match _type:
		"int":
			default_value = clamp(int(default_value), int(_lower_limit), int(_upper_limit))
		"float":
			default_value = clamp(float(default_value), float(_lower_limit), float(_upper_limit))
		_:
			pass

func _clamp_value_if_needed() -> void:
	if not _use_limits or value == null:
		return
	match _type:
		"int":
			value = clamp(int(value), int(_lower_limit), int(_upper_limit))
		"float":
			value = clamp(float(value), float(_lower_limit), float(_upper_limit))
		_:
			pass
