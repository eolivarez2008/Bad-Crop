extends Area2D

const PepperScene := preload("res://scenes/pepper.tscn")

var speed := 90.0
var max_health := 30
var health := 30
var contact_damage := 10
var pepper_table: Array = []

var target: Node2D = null
var _dead := false
var _move_dir: Vector2 = Vector2.ZERO
var _anim_scale: Vector2 = Vector2.ONE
var _time: float = 0.0

const FLASH_DURATION: float = 0.1
const SQUASH_DURATION: float = 0.12
const COLOR_HIT := Color(10.0, 10.0, 10.0)

var _flash_timer: float = 0.0
var _squash_timer: float = 0.0

@onready var visual := $Body
@onready var col_shape := $CollisionShape2D

func _ready() -> void:
	_apply_visuals()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _apply_visuals() -> void:
	if visual:
		_anim_scale = visual.scale

func init(player: Node2D, health_mult: float, speed_mult: float) -> void:
	target = player
	max_health = int(max_health * health_mult)
	health = max_health
	speed = speed * speed_mult
	contact_damage = int(contact_damage * health_mult)

func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	_flash_timer = FLASH_DURATION
	_squash_timer = SQUASH_DURATION
	if health <= 0:
		die(true)

func die(should_drop: bool) -> void:
	if _dead:
		return
	_dead = true
	if should_drop:
		_drop_pepper()
	queue_free()

func _drop_pepper() -> void:
	var roll: float = randf()
	var cumulative: float = 0.0
	var chosen_type: int = 0
	for entry in pepper_table:
		cumulative += entry["chance"]
		if roll <= cumulative:
			chosen_type = entry["type"]
			break
	var pepper := PepperScene.instantiate()
	pepper.global_position = global_position
	get_tree().current_scene.add_child(pepper)
	pepper.init(chosen_type)

func _process(delta: float) -> void:
	_time += delta
	_update_procedural_animations(delta)

func _update_procedural_animations(delta: float) -> void:
	_flash_timer -= delta
	_squash_timer -= delta

	if _flash_timer > 0.0:
		visual.modulate = COLOR_HIT
	else:
		visual.modulate = Color.WHITE

	var base_scale: Vector2 = _anim_scale

	if _squash_timer > 0.0:
		var t: float = _squash_timer / SQUASH_DURATION
		visual.scale = base_scale * Vector2(1.0 + 0.4 * t, 1.0 - 0.4 * t)
		return

	if _move_dir != Vector2.ZERO:
		var bounce: float = sin(_time * 14.0) * 0.05
		var sx: float = 1.0 + abs(_move_dir.x) * 0.15 - abs(_move_dir.y) * 0.08 + bounce
		var sy: float = 1.0 + abs(_move_dir.y) * 0.15 - abs(_move_dir.x) * 0.08 - bounce
		visual.scale = visual.scale.lerp(base_scale * Vector2(sx, sy), 0.2)
	else:
		visual.scale = visual.scale.lerp(base_scale, 0.15)

func _physics_process(delta: float) -> void:
	if target == null or _dead:
		return
	_move_dir = (target.global_position - global_position).normalized()
	global_position += _move_dir * speed * delta
	
	if visual:
		if _move_dir.x < 0:
			visual.flip_h = true
		elif _move_dir.x > 0:
			visual.flip_h = false

func _on_body_entered(body_node: Node) -> void:
	if body_node.is_in_group("player"):
		body_node.take_damage(contact_damage)
		die(false)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile"):
		take_damage(area.get_damage())
		area.queue_free()
