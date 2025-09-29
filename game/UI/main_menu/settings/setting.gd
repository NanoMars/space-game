@tool
extends Resource
class_name Setting

var game_started: bool = false
@export var name: String
@export var display: bool = true
@export_enum("bool", "int", "float", "string", "color") var type: String:
	get:
		return _type
	set(value):
		_type = value
		_set_thing()

var _type: String = "bool"
# Replace plain vars with backed properties so "value" follows "default_value" until overridden.
var _default_value: Variant = null
var default_value: Variant:
	get: return _default_value
	set(v):
		_default_value = v
		_clamp_default_if_needed()
		if _value_is_default:
			_value = _default_value

var _value: Variant = null
	
var _value_is_default: bool = true
var value: Variant:
	get: 
		return _value
	set(v):
		_value = v
		_clamp_value_if_needed()
		_value_is_default = (_value == _default_value)

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
	get: 
		return _upper_limit
	set(value):
		_upper_limit = value
		if _use_limits and _upper_limit < _lower_limit:
			_lower_limit = _upper_limit
		_clamp_default_if_needed()
		_clamp_value_if_needed()

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
				default_desc["hint_string"] = "%s,%s" % [str(_lower_limit), str(_upper_limit)]
	list.append(default_desc)

	var value_desc := {
		"name": "value",
		"type": t,
		"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_NO_EDITOR,
	}
	list.append(value_desc)

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

# New: helper to determine the default for the current type.
func _default_for_type() -> Variant:
	match _type:
		"bool":
			return false
		"int":
			return 0
		"float":
			return 0.0
		"string":
			return ""
		"color":
			return Color.AQUA
		_:
			return null

# Initialize defaults when the Resource is constructed (works in editor and at runtime).
func _init():
	if _default_value == null and _value == null:
		default_value = _default_for_type()
		value = default_value
	_clamp_default_if_needed()
	_clamp_value_if_needed()
	notify_property_list_changed()

# Do not mutate default_value/value here; only refresh the inspector and clamp.
func _set_thing() -> void:
	notify_property_list_changed()
	_clamp_default_if_needed()
	_clamp_value_if_needed()
	if _value_is_default:
		_value = _default_value
func _ready() -> void:
	game_started = true

func _clamp_default_if_needed() -> void:
	if not _use_limits or _default_value == null or not game_started:
		return
	
	var clamped_default: Variant
	match _type:
		"int":
			clamped_default = clamp(int(_default_value), int(_lower_limit), int(_upper_limit))
		"float":
			clamped_default = clamp(float(_default_value), float(_lower_limit), float(_upper_limit))
		_:
			return
	if clamped_default != _default_value:
		_default_value = clamped_default

func _clamp_value_if_needed() -> void:
	if not _use_limits or _value == null or not game_started:
		return
	
	var clamped_value: Variant
	match _type:
		"int":
			clamped_value = clamp(int(_value), int(_lower_limit), int(_upper_limit))
		"float":
			clamped_value = clamp(float(_value), float(_lower_limit), float(_upper_limit))
		_:
			return
	
	# Only update if the value actually changed
	if clamped_value != _value:
		
		_value = clamped_value
