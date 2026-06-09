extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	speed = 55.0
	max_health = 90
	health = 90
	contact_damage = 25
	pepper_table = [
		{ "type": 2, "chance": 1 },
	]
	super._ready()
