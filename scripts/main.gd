extends Node2D

@onready var player := $Player
@onready var enemy_spawner := $EnemySpawner

func _ready() -> void:
	enemy_spawner.init(player)
	enemy_spawner.start()

func _process(delta: float) -> void:
	_update_nearest_enemy()

func _update_nearest_enemy() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var min_dist := INF

	for enemy in enemies:
		var dist : float = player.global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	player.set_nearest_enemy(nearest)
