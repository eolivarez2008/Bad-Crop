extends Node2D

@onready var player := $Player
@onready var enemy_spawner := $EnemySpawner

func _ready() -> void:
	enemy_spawner.init(player)
	enemy_spawner.start()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.die()
