extends Node2D

@onready var nav_region := $NavRegion2D
@onready var player := $Entities/Player
@onready var enemy_spawner := $EnemySpawner
@onready var wave_manager := $WaveManager
@onready var hud := $HUD
@onready var shop := $Shop
@onready var game_over := $GameOver

func _ready() -> void:
	if player and hud:
		player.hud = hud
	enemy_spawner.init(player)
	wave_manager.init(enemy_spawner)
	shop.init(player)
	wave_manager.wave_ended.connect(_on_wave_ended)
	wave_manager.wave_started.connect(_on_wave_started)
	shop.closed.connect(_on_shop_closed)
	await get_tree().process_frame
	_generate_collision_from_navigation()
	wave_manager.start_next_wave()

func _generate_collision_from_navigation() -> void:
	if not nav_region or not nav_region.navigation_polygon:
		return

	var static_body := StaticBody2D.new()
	static_body.collision_layer = 4
	static_body.collision_mask = 0
	nav_region.add_child(static_body)

	var outline_count: int = nav_region.navigation_polygon.get_outline_count()
	for i in range(outline_count):
		var outline_points: PackedVector2Array = nav_region.navigation_polygon.get_outline(i)
		if outline_points.size() < 3:
			continue
			
		var collision_polygon := CollisionPolygon2D.new()
		collision_polygon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
		collision_polygon.polygon = outline_points
		static_body.add_child(collision_polygon)

func _process(_delta: float) -> void:
	if player and hud and wave_manager:
		hud.update_health(player.health, player.max_health)
		hud.update_peppers(player.peppers)
		hud.update_timer(wave_manager.time_remaining)
		hud.update_spicy(player.spicy_level, player.spicy_xp, player._xp_for_next_level())
		_check_player_dead()

func _check_player_dead() -> void:
	if player.health <= 0:
		game_over.show_game_over(wave_manager.current_wave)

func _on_wave_started(wave_number: int) -> void:
	hud.update_wave(wave_number)

func _on_wave_ended(wave_number: int) -> void:
	player.set_active(false)
	_clear_indicators()
	_clear_peppers()
	_clear_enemies()
	_regen_player()
	await get_tree().create_timer(0.6).timeout
	shop.open()

func _on_shop_closed() -> void:
	player.set_active(true)
	wave_manager.start_next_wave()

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.die(false, true)

func _clear_indicators() -> void:
	for indicator in get_tree().get_nodes_in_group("indicators"):
		if is_instance_valid(indicator):
			indicator.queue_free()

func _clear_peppers() -> void:
	for pepper in get_tree().get_nodes_in_group("peppers"):
		if is_instance_valid(pepper):
			var tween := pepper.create_tween()
			tween.tween_property(pepper, "modulate:a", 0.0, 1.5)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween.tween_callback(pepper.queue_free)

func _regen_player() -> void:
	player.health = player.max_health
