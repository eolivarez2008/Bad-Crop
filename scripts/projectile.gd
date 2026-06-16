extends Area2D

var speed := 400.0
var damage := 10
var direction := Vector2.ZERO
var _is_destroying := false

@onready var body: Sprite2D = $Body

func init(dir: Vector2, dmg: int) -> void:
	direction = dir.normalized()
	damage = dmg
	rotation = direction.angle()

func get_damage() -> int:
	return damage

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if _is_destroying:
		return
		
	if area.name == "Hitbox" and is_instance_valid(area):
		var parent = area.get_parent()
		if parent and parent.has_method("take_damage"):
			parent.take_damage(damage)
			queue_free()

func _on_body_entered(body_node: Node) -> void:
	if _is_destroying:
		return

	if body_node is StaticBody2D and body_node.collision_layer == 4:
		_fade_out_and_destroy()

func _fade_out_and_destroy() -> void:
	_is_destroying = true
	
	monitoring = false
	monitorable = false
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	tween.tween_callback(queue_free)