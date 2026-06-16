extends CharacterBody2D

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

var is_infected: bool = false
var infected_speed_mult: float = 1.5
var infected_target: Node2D = null
var _zigzag_time: float = 0.0
var _zigzag_seed: float = 0.0
var _isolation_check_timer: float = 0.0
const ISOLATION_CHECK_INTERVAL: float = 0.5
const ISOLATION_RADIUS: float = 600.0

@onready var nav_agent := $NavigationAgent2D
@onready var hitbox := $Hitbox
@onready var visual := $Body
@onready var icon_mind_control: TextureRect = $IconMindControl
@onready var mind_control_trail: CPUParticles2D = $MindControlTrail
@onready var health_bar: ProgressBar = $HealthBar
@onready var blood_splatter: GPUParticles2D = $BloodSplatter

func _ready() -> void:
	add_to_group("enemies")
	_apply_visuals()
		
	if hitbox:
		hitbox.body_entered.connect(_on_body_entered)
		hitbox.area_entered.connect(_on_area_entered)
	_zigzag_seed = randf() * TAU
	if icon_mind_control:
		icon_mind_control.visible = false
	if mind_control_trail:
		mind_control_trail.emitting = false
	if health_bar:
		health_bar.visible = false

func _update_health_bar() -> void:
	if not is_instance_valid(health_bar):
		return
	var pct := float(health) / float(max_health)
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = pct < 1.0 and not is_infected

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
	_update_health_bar()
	if health <= 0:
		die(true, true)

func die(should_drop: bool, spawn_blood: bool) -> void:
	if _dead:
		return
	_dead = true
	
	if should_drop:
		_drop_pepper()
		
	if spawn_blood:
		_spawn_blood_splatter()
		
	queue_free()

func _spawn_blood_splatter() -> void:
	if not is_instance_valid(blood_splatter):
		return
	blood_splatter.reparent(get_tree().current_scene)
	blood_splatter.emitting = true
	var timer := blood_splatter.get_tree().create_timer(blood_splatter.lifetime + 0.1)
	timer.timeout.connect(blood_splatter.queue_free)

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

func infect() -> void:
	if is_infected or _dead:
		return
	is_infected = true
	if icon_mind_control:
		icon_mind_control.visible = true
	if mind_control_trail:
		mind_control_trail.emitting = true
	_isolation_check_timer = ISOLATION_CHECK_INTERVAL
	_update_health_bar()

func _process(delta: float) -> void:
	_time += delta
	_update_procedural_animations(delta)
	if is_infected:
		_update_isolation_check(delta)

func _update_isolation_check(delta: float) -> void:
	_isolation_check_timer -= delta
	if _isolation_check_timer > 0.0:
		return
	_isolation_check_timer = ISOLATION_CHECK_INTERVAL

	if _count_other_infected_in_range() == 0:
		die(false, true)

func _count_other_infected_in_range() -> int:
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self or not is_instance_valid(enemy):
			continue
		if enemy.is_infected and not enemy._dead:
			if global_position.distance_to(enemy.global_position) <= ISOLATION_RADIUS:
				count += 1
	return count

func _update_procedural_animations(delta: float) -> void:
	_flash_timer -= delta
	_squash_timer -= delta

	if _flash_timer > 0.0:
		visual.modulate = COLOR_HIT
	elif is_infected:
		visual.modulate = Color(1.6, 0.6, 1.8)
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

func _physics_process(_delta: float) -> void:
	if _dead:
		return

	if is_infected:
		_physics_infected(_delta)
		return

	if target == null:
		return

	nav_agent.target_position = target.global_position
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		_move_dir = Vector2.ZERO
		return

	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	_move_dir = global_position.direction_to(next_path_pos)
	
	velocity = _move_dir * speed
	move_and_slide()

	if visual and _move_dir.x != 0:
		visual.flip_h = _move_dir.x < 0

func _physics_infected(_delta: float) -> void:
	_zigzag_time += _delta

	if infected_target == null or not is_instance_valid(infected_target) or !infected_target.is_infected or infected_target._dead:
		infected_target = _find_nearest_infected()

	if infected_target == null:
		velocity = Vector2.ZERO
		_move_dir = Vector2.ZERO
		move_and_slide()
		return

	nav_agent.target_position = infected_target.global_position
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		_move_dir = Vector2.ZERO
		return

	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var base_dir := global_position.direction_to(next_path_pos)
	
	var perp := Vector2(-base_dir.y, base_dir.x)
	var zigzag: float = sin(_zigzag_time * 8.0 + _zigzag_seed) * 0.6
	_move_dir = (base_dir + perp * zigzag).normalized()

	velocity = _move_dir * speed * infected_speed_mult
	move_and_slide()

	if visual and _move_dir.x != 0:
		visual.flip_h = _move_dir.x < 0

func _find_nearest_infected() -> Node2D:
	var closest: Node2D = null
	var min_dist := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self or not is_instance_valid(enemy):
			continue
		if not enemy.is_infected or enemy._dead:
			continue
		var dist: float = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest

func _on_body_entered(body_node: Node) -> void:
	if is_infected:
		return
	if body_node.is_in_group("player"):
		body_node.take_damage(contact_damage)
		die(false, false)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile"):
		take_damage(area.get_damage())
		area.queue_free()
		return

	if is_infected and area.is_in_group("enemies") and area.is_infected and not area._dead and not _dead:
		die(false, true)
		if is_instance_valid(area):
			area.die(false, true)