extends Area2D

var speed := 400.0
var damage := 10
var direction := Vector2.ZERO

func init(dir: Vector2, dmg: int) -> void:
	direction = dir.normalized()
	damage = dmg

func get_damage() -> int:
	return damage

func _ready() -> void:
	add_to_group("projectile")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()
