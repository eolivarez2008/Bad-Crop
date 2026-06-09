extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	speed = 160.0
	max_health = 18
	health = 18
	contact_damage = 15
	pepper_table = [
		{ "type": 1, "chance": 1 },
	]
	super._ready()
