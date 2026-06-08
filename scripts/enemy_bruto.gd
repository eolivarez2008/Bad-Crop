extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	speed = 55.0
	max_health = 90
	health = 90
	contact_damage = 25
	body_size = Vector2(52, 52)
	body_color = Color(0.55, 0.20, 0.80)
	pepper_table = [
		{ "type": 1, "chance": 0.50 },
		{ "type": 2, "chance": 0.50 },
	]
	super._ready()
