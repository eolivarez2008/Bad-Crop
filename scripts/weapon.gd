extends Node2D

const ProjectileScene := preload("res://scenes/projectile.tscn")

var flip_base: bool = false

var damage := 10
var fire_rate := 1.0
var target: Node2D = null

var _timer := 0.0

@onready var body: Sprite2D = $Body

func init(dmg: int, rate: float) -> void:
	damage = dmg
	fire_rate = rate
	body.flip_v = flip_base

func set_target(t: Node2D) -> void:
	target = t

func _process(delta: float) -> void:
	_timer += delta

	if target == null or not is_instance_valid(target):
		target = null
		return

	var dir: Vector2 = target.global_position - global_position
	rotation = atan2(dir.y, dir.x)
	body.flip_v = dir.x < 0.0

	if _timer >= fire_rate:
		_timer = 0.0
		_shoot()

func _shoot() -> void:
	var projectile := ProjectileScene.instantiate()
	var dir: Vector2 = (target.global_position - global_position).normalized()
	projectile.global_position = global_position
	
	get_tree().current_scene.add_child(projectile)
	
	projectile.init(dir, damage)
