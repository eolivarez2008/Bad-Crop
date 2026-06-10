extends Area2D

var speed := 400.0
var damage := 10
var direction := Vector2.ZERO

@onready var body: Sprite2D = $Body

func init(dir: Vector2, dmg: int) -> void:
	direction = dir.normalized()
	damage = dmg
	
	rotation = direction.angle()

func get_damage() -> int:
	return damage

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	queue_free()
