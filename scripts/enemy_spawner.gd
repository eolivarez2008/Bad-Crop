extends Node2D

const ENEMY_SCENES := {
	"slimek": preload("res://scenes/enemy_slimek.tscn"),
	"bruto":  preload("res://scenes/enemy_bruto.tscn"),
	"zapper": preload("res://scenes/enemy_zapper.tscn"),
}

const SPAWN_WEIGHTS := {
	"slimek": 0.65,
	"bruto":  0.25,
	"zapper": 0.10,
}

@export var spawn_rect := Rect2(0, 0, 1280, 720)

var player: Node2D = null
var spawn_interval := 2.0
var health_mult := 1.0
var speed_mult := 1.0

@onready var timer := $SpawnTimer

func init(p: Node2D) -> void:
	player = p

func set_wave_params(interval: float, h_mult: float, s_mult: float) -> void:
	spawn_interval = interval
	health_mult = h_mult
	speed_mult = s_mult

func start() -> void:
	timer.wait_time = spawn_interval
	timer.start()

func stop() -> void:
	timer.stop()

func _on_spawn_timer_timeout() -> void:
	if player == null:
		return
	var enemy_key := _pick_enemy_type()
	var enemy : Area2D = ENEMY_SCENES[enemy_key].instantiate()
	enemy.global_position = _random_spawn_position()
	get_parent().add_child(enemy)
	enemy.init(player, health_mult, speed_mult)

func _pick_enemy_type() -> String:
	var roll := randf()
	var cumulative := 0.0
	for key in SPAWN_WEIGHTS:
		cumulative += SPAWN_WEIGHTS[key]
		if roll <= cumulative:
			return key
	return "slimek"

func _random_spawn_position() -> Vector2:
	return Vector2(
		randf_range(spawn_rect.position.x, spawn_rect.end.x),
		randf_range(spawn_rect.position.y, spawn_rect.end.y)
	)
