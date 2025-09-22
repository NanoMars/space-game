extends Control

@export var settings: Array[Setting]:
	set(value):
		Settings._settings = value
	get:
		return Settings._settings

@export var custom_theme: Theme
@export var container: Container

func _ready() -> void:
	for setting in settings:
		# Ensure the setting has a stored value.
		if setting.value == null:
			setting.value = setting.default_value

		match setting.type:
			"bool":
				var check_button: CheckButton = CheckButton.new()
				check_button.text = setting.name
				check_button.set_pressed(bool(setting.value))
				check_button.toggled.connect(func(pressed: bool, setting_name=setting.name):
					Settings._set(setting_name, pressed)
				)
				check_button.theme = custom_theme
				container.add_child(check_button)
			"int":
				if setting._use_limits and setting.lower_limit >= setting.upper_limit:
					push_error("Setting %s has invalid limits: lower_limit (%f) must be less than upper_limit (%f)" % [setting.name, setting.lower_limit, setting.upper_limit])
				elif setting._use_limits:
					var vbox: VBoxContainer = VBoxContainer.new()
					var label: Label = Label.new()
					label.text = setting.name
					label.theme = custom_theme
					var slider: HSlider = HSlider.new()
					slider.min_value = setting.lower_limit
					slider.max_value = setting.upper_limit
					slider.step = 1
					slider.theme = custom_theme
					slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					slider.drag_ended.connect(func(_value_changed: bool, setting_name=setting.name, slider_ref=slider):
						Settings._set(setting_name, int(slider_ref.value))
					)
					vbox.add_child(label)
					vbox.add_child(slider)
					slider.value = int(setting.value)
					container.add_child(vbox)
				else:
					var spin_box: SpinBox = SpinBox.new()
					spin_box.step = 1
					spin_box.page = 10
					spin_box.theme = custom_theme
					spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					var label2: Label = Label.new()
					label2.text = setting.name
					label2.theme = custom_theme
					var vbox2: VBoxContainer = VBoxContainer.new()
					vbox2.add_child(label2)
					vbox2.add_child(spin_box)
					spin_box.value = int(setting.value)
					spin_box.value_changed.connect(func(value: float, setting_name=setting.name):
						Settings._set(setting_name, int(value))
					)
					container.add_child(vbox2)
			"float":
				if setting._use_limits and setting.lower_limit >= setting.upper_limit:
					push_error("Setting %s has invalid limits: lower_limit (%f) must be less than upper_limit (%f)" % [setting.name, setting.lower_limit, setting.upper_limit])
				elif setting._use_limits:
					var vbox_f: VBoxContainer = VBoxContainer.new()
					var label_f: Label = Label.new()
					label_f.text = setting.name
					label_f.theme = custom_theme
					var slider_f: HSlider = HSlider.new()
					slider_f.min_value = setting.lower_limit
					slider_f.max_value = setting.upper_limit
					slider_f.step = 0.01
					slider_f.theme = custom_theme
					slider_f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					slider_f.drag_ended.connect(func(_value_changed: bool, setting_name=setting.name, slider_ref=slider_f):
						Settings._set(setting_name, float(slider_ref.value))
					)
					vbox_f.add_child(label_f)
					vbox_f.add_child(slider_f)
					slider_f.value = float(setting.value)
					container.add_child(vbox_f)
				else:
					var spin_box_f: SpinBox = SpinBox.new()
					spin_box_f.step = 0.1
					spin_box_f.page = 1.0
					spin_box_f.theme = custom_theme
					spin_box_f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					var label2_f: Label = Label.new()
					label2_f.text = setting.name
					label2_f.theme = custom_theme
					var vbox2_f: VBoxContainer = VBoxContainer.new()
					vbox2_f.add_child(label2_f)
					vbox2_f.add_child(spin_box_f)
					spin_box_f.value = float(setting.value)
					spin_box_f.value_changed.connect(func(value: float, setting_name=setting.name):
						Settings._set(setting_name, float(value))
					)
					container.add_child(vbox2_f)
			"string":
				var vbox: VBoxContainer = VBoxContainer.new()
				var label_s: Label = Label.new()
				label_s.text = setting.name
				label_s.theme = custom_theme
				var line_edit: LineEdit = LineEdit.new()
				line_edit.text = String(setting.value)
				line_edit.theme = custom_theme
				line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				line_edit.text_changed.connect(func(new_text: String, setting_name=setting.name):
					Settings._set(setting_name, new_text)
				)
				vbox.add_child(label_s)
				vbox.add_child(line_edit)
				container.add_child(vbox)
			"color":
				var hbox_c: HBoxContainer = HBoxContainer.new()
				var label_c: Label = Label.new()
				label_c.text = setting.name
				label_c.theme = custom_theme
				label_c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var color_picker: ColorPickerButton = ColorPickerButton.new()
				color_picker.color = Color(setting.value)
				color_picker.theme = custom_theme
				color_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				color_picker.color_changed.connect(func(new_color: Color, setting_name=setting.name):
					Settings._set(setting_name, new_color)
				)
				color_picker.size_flags_horizontal = Control.SIZE_SHRINK_END
				color_picker.custom_minimum_size = Vector2(16, 16)
				hbox_c.add_child(label_c)
				hbox_c.add_child(color_picker)
				container.add_child(hbox_c)
			_:
				push_error("Unknown setting type: %s" % setting.type)
				Settings._set(setting.name, setting.default_value)
			
