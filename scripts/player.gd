extends CharacterBody2D

@export var camera_margin := 190.0

@export var shake_decay := 4.0
var _shake_intensity := 0.0

@export var look_ahead_distance := 50.0
@export var look_ahead_speed := 3.0

var speed := 200.0
var max_health := 100
var health := 100
var peppers := 0

@onready var weapon_left := $WeaponLeft
@onready var weapon_right := $WeaponRight
@onready var hud: CanvasLayer = $"../hud"
@onready var body := $Body
@onready var arena := $"../Arena"
@onready var camera := $Camera

const COLOR_NORMAL := Color(1.0, 1.0, 1.0)
const COLOR_HIT := Color(10.0, 10.0, 10.0)
const FLASH_DURATION: float = 0.1
const SQUASH_DURATION: float = 0.15

var _flash_timer: float = 0.0
var _squash_timer: float = 0.0
var _anim_scale: Vector2 = Vector2.ONE
var _time: float = 0.0
var _is_moving: bool = false
var _last_direction := Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	weapon_left.init(10, 1.0)
	weapon_right.init(10, 1.5)
	
	if hud:
		hud.update_health(health, max_health)
		
	_setup_camera()

func _setup_camera() -> void:
	if not camera:
		return
		
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	
	if arena:
		camera.limit_left = int(arena.ARENA_CENTER.x - arena.ARENA_RX - camera_margin)
		camera.limit_right = int(arena.ARENA_CENTER.x + arena.ARENA_RX + camera_margin)
		camera.limit_top = int(arena.ARENA_CENTER.y - arena.ARENA_RY - camera_margin)
		camera.limit_bottom = int(arena.ARENA_CENTER.y + arena.ARENA_RY + camera_margin)

func add_peppers(amount: int) -> void:
	peppers += amount

func set_nearest_enemy(enemy: Node2D) -> void:
	weapon_left.set_target(enemy)
	weapon_right.set_target(enemy)

# Applique les dégâts et déclenche le tremblement d'écran
func take_damage(amount: int) -> void:
	health -= amount
	health = max(0, health)
	_flash_timer = FLASH_DURATION
	_squash_timer = SQUASH_DURATION
	
	# Ajoute une intensité de tremblement (ex: 15 pixels de secousse)
	_shake_intensity = 15.0
	
	if hud:
		hud.update_health(health, max_health)

func _process(delta: float) -> void:
	_time += delta
	_update_procedural_animations(delta)
	_update_camera_effects(delta)

# Gère le Screen Shake et l'Anticipation de la caméra
func _update_camera_effects(delta: float) -> void:
	if not camera:
		return
		
	# 1. Calcul du Look-Ahead (décale la caméra vers là où on court)
	var target_camera_pos = Vector2.ZERO
	if _is_moving:
		target_camera_pos = _last_direction * look_ahead_distance
		
	# Transition fluide vers la position d'anticipation
	camera.position = camera.position.lerp(target_camera_pos, look_ahead_speed * delta)
	
	# 2. Calcul du Screen Shake (ajoute un décalage aléatoire destructuré)
	if _shake_intensity > 0.0:
		_shake_intensity = move_toward(_shake_intensity, 0.0, shake_decay * delta)
		var shake_offset := Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		camera.position += shake_offset

func _update_procedural_animations(delta: float) -> void:
	_flash_timer -= delta
	_squash_timer -= delta

	if _flash_timer > 0.0:
		body.modulate = COLOR_HIT
	else:
		body.modulate = COLOR_NORMAL

	if _squash_timer > 0.0:
		var t: float = _squash_timer / SQUASH_DURATION
		var hit_scale: Vector2 = Vector2(1.0 + 0.4 * t, 1.0 - 0.4 * t)
		_anim_scale = _anim_scale.lerp(hit_scale, 0.5)
		scale = _anim_scale
		return

	if _is_moving:
		var breathe: float = sin(_time * 16.0) * 0.04
		var target_scale: Vector2 = Vector2(1.0 + breathe, 1.0 - breathe)
		_anim_scale = _anim_scale.lerp(target_scale, 0.25)
	else:
		var idle: float = sin(_time * 7.0) * 0.04
		var target_scale: Vector2 = Vector2(1.0 - idle, 1.0 + idle)
		_anim_scale = _anim_scale.lerp(target_scale, 0.12)

	scale = _anim_scale

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		_is_moving = true
		_last_direction = direction
		
		if direction.x < 0:
			body.flip_h = true
		elif direction.x > 0:
			body.flip_h = false
	else:
		_is_moving = false

	velocity = direction * speed
	move_and_slide()
