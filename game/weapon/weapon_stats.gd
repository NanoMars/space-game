# weapon_stats.gd
extends Resource
class_name WeaponStats

@export var damage: float = 10.0
@export var fire_rate: float = 3.0
@export var projectile_speed: float = 60.0
@export var projectile_scene: PackedScene
@export var fire_pattern: FirePattern
@export var movement: Script
@export var sound_effect: AudioStream
@export var sound_volume_db: float = 0.0