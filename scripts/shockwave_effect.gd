extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var line_2d_inner: Line2D = $Line2DInner
@onready var gp_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var flash: Sprite2D = $Flash
@onready var damage_area: Area2D = $DamageArea
@onready var collision_shape: CollisionShape2D = $DamageArea/CollisionShape2D

var target_radius: float = 200.0
var duration: float = 0.4
var initial_thickness: float = 12.0
var current_radius: float = 0.0

func _ready() -> void:
	line_2d.width = initial_thickness
	line_2d_inner.width = initial_thickness * 2.0
	gp_particles_2d.emitting = true

	flash.scale = Vector2(target_radius / 32.0, target_radius / 32.0)

	var tween = create_tween().set_parallel(true)

	tween.tween_property(self, "current_radius", target_radius, duration)\
		.set_trans(Tween.TransitionType.TRANS_CUBIC)\
		.set_ease(Tween.EaseType.EASE_OUT)

	tween.tween_property(line_2d, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TransitionType.TRANS_LINEAR)\
		.set_ease(Tween.EaseType.EASE_IN)

	tween.tween_property(line_2d_inner, "modulate:a", 0.0, duration * 0.6)\
		.set_trans(Tween.TransitionType.TRANS_LINEAR)\
		.set_ease(Tween.EaseType.EASE_IN)

	tween.tween_property(flash, "modulate:a", 0.0, 0.15)\
		.set_trans(Tween.TransitionType.TRANS_EXPO)\
		.set_ease(Tween.EaseType.EASE_OUT)

	tween.chain().tween_callback(queue_free)

func _on_damage_area_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
		
	var target = area
	if not area.is_in_group("enemies") and area.get_parent() and area.get_parent().is_in_group("enemies"):
		target = area.get_parent()
		
	if target.is_in_group("enemies"):
		if target.has_method("die"):
			target.die(true)
		elif area.has_method("die"):
			area.die(true)
		else:
			target.queue_free()

func _process(_delta: float) -> void:
	_update_circle_points()
	
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = max(1.0, current_radius)

func _update_circle_points() -> void:
	var points_outer := PackedVector2Array()
	var points_inner := PackedVector2Array()
	var num_points := 64

	for i in range(num_points):
		var angle := (i * 2.0 * PI) / num_points
		var dir := Vector2(cos(angle), sin(angle))
		points_outer.append(dir * current_radius)
		points_inner.append(dir * current_radius * 0.92)

	line_2d.points = points_outer
	line_2d_inner.points = points_inner