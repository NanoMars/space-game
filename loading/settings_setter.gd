extends Node

@export var settings: Array[Setting]:
	set(value):
		Settings._settings = value
	get:
		return Settings._settings