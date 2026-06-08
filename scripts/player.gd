extends CharacterBody2D

var speed := 200.0
var max_health := 100
var health := 100
var peppers := 0

const ARENA_MIN := Vector2(40, 40)
const ARENA_MAX := Vector2(1240, 680)

@onready var weapon_left := $WeaponLeft
@onready var weapon_right := $WeaponRight
@onready var hud: CanvasLayer = $"../hud"
@onready var body := $Body

const COLOR_NORMAL := Color(0.29, 0.56, 0.85)
const COLOR_HIT := Color(1.0, 1.0, 1.0)
const FLASH_DURATION: float = 0.1

var _flash_timer: float = 0.0
var _time: float = 0.0
var _target_scale: Vector2 = Vector2.ONE
var _current_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	add_to_group("player")
	weapon_left.init(10, 1.0)
	weapon_right.init(10, 1.5)
	if hud:
		hud.update_health(health, max_health)
	
	if body:
		body.pivot_offset = body.size / 2.0

func add_peppers(amount: int) -> void:
	peppers += amount

func set_nearest_enemy(enemy: Node2D) -> void:
	weapon_left.set_target(enemy)
	weapon_right.set_target(enemy)

func take_damage(amount: int) -> void:
	health -= amount
	health = max(0, health)
	_flash_timer = FLASH_DURATION
	_current_scale = Vector2(1.4, 0.6)
	if hud:
		hud.update_health(health, max_health)

func _process(delta: float) -> void:
	_time += delta
	
	_flash_timer -= delta
	if _flash_timer > 0.0:
		body.color = COLOR_HIT
	else:
		body.color = COLOR_NORMAL
	
	if velocity.length() > 0.1:
		var speed_factor: float = velocity.length() / speed
		var wave: float = sin(_time * 18.0) * 0.08 * speed_factor
		_target_scale = Vector2(1.0 + wave + (speed_factor * 0.05), 1.0 - wave - (speed_factor * 0.05))
	else:
		var wave: float = sin(_time * 18.0) * 0.08
		_target_scale = Vector2(1.0 + wave, 1.0 - wave)
	
	_current_scale = _current_scale.lerp(_target_scale, 12.0 * delta)
	body.scale = _current_scale

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()
	position = position.clamp(ARENA_MIN, ARENA_MAX)
