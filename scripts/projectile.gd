extends Area2D

var speed := 400.0
var damage := 10
var direction := Vector2.ZERO

func init(dir: Vector2, dmg: int) -> void:
	direction = dir.normalized()
	damage = dmg

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	var screen := get_viewport_rect()
	if not screen.has_point(global_position):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
