extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	speed = 160.0
	max_health = 18
	health = 18
	contact_damage = 15
	body_size = Vector2(24, 24)
	body_color = Color(0.95, 0.80, 0.10)
	pepper_table = [
		{ "type": 0, "chance": 0.60 },
		{ "type": 1, "chance": 0.40 },
	]
	super._ready()
