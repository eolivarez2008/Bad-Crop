extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	speed = 90.0
	max_health = 30
	health = 30
	contact_damage = 10
	pepper_table = [
		{ "type": 0, "chance": 1 },
	]
	super._ready()
