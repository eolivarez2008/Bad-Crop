extends "res://scripts/enemy_base.gd"

func _ready() -> void:
	speed = 90.0
	max_health = 30
	health = 30
	contact_damage = 10
	body_size = Vector2(36, 36)
	body_color = Color(0.91, 0.30, 0.24)
	pepper_table = [
		{ "type": 0, "chance": 0.70 },
		{ "type": 1, "chance": 0.30 },
	]
	super._ready()
