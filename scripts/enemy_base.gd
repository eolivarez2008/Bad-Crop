extends Area2D

const PepperScene := preload("res://scenes/pepper.tscn")

var speed := 90.0
var max_health := 30
var health := 30
var contact_damage := 10
var body_size := Vector2(36, 36)
var body_color := Color(0.91, 0.30, 0.24)
var pepper_table: Array = []

var target: Node2D = null
var _dead := false
var _flash_timer := 0.0

const FLASH_DURATION := 0.1
const COLOR_HIT := Color(1.0, 1.0, 1.0)

@onready var visual := $Body
@onready var col_shape := $CollisionShape2D

func _ready() -> void:
	_apply_visuals()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _apply_visuals() -> void:
	visual.color = body_color
	visual.offset_left = -body_size.x / 2
	visual.offset_top = -body_size.y / 2
	visual.offset_right = body_size.x / 2
	visual.offset_bottom = body_size.y / 2
	var rect := RectangleShape2D.new()
	rect.size = body_size
	col_shape.shape = rect

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
	var roll := randf()
	var cumulative := 0.0
	var chosen_type := 0
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
	if _flash_timer > 0.0:
		_flash_timer -= delta
		visual.color = COLOR_HIT
	else:
		visual.color = body_color

func _physics_process(delta: float) -> void:
	if target == null or _dead:
		return
	var dir := (target.global_position - global_position).normalized()
	global_position += dir * speed * delta

func _on_body_entered(body_node: Node) -> void:
	if body_node.is_in_group("player"):
		body_node.take_damage(contact_damage)
		die(false)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile"):
		take_damage(area.get_damage())
		area.queue_free()
