extends Area2D

enum Type { GREEN, YELLOW, RED }

const VALUES := {
	Type.GREEN: 5,
	Type.YELLOW: 15,
	Type.RED: 40
}

@export var REGIONS := {
	Type.GREEN: Rect2(890, 40, 60, 80),
	Type.YELLOW: Rect2(890, 140, 60, 80),
	Type.RED: Rect2(890, 240, 60, 80) 
}

var type: Type = Type.GREEN
var value: int = 5

var _scale_timer := 0.0
const POP_DURATION := 0.2

@onready var body: Sprite2D = $Body

func init(t: Type) -> void:
	type = t
	value = VALUES[t]
	scale = Vector2(0.5, 0.5)
	_scale_timer = POP_DURATION
	
	if body:
		body.region_rect = REGIONS[t]

func _process(delta: float) -> void:
	if _scale_timer > 0.0:
		_scale_timer -= delta
		var t := 1.0 - (_scale_timer / POP_DURATION)
		scale = Vector2.ONE * lerp(0.5, 1.0, t)

func _on_body_entered(body_node: Node) -> void:
	if body_node.is_in_group("player"):
		body_node.add_peppers(value)
		queue_free()
