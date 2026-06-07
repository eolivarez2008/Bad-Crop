extends CharacterBody2D

@export var speed := 200.0

const ARENA_MIN := Vector2(40, 40)
const ARENA_MAX := Vector2(1240, 680)

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	position = position.clamp(ARENA_MIN, ARENA_MAX)
