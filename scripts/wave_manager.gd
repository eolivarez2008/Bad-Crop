extends Node

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)

var current_wave := 0
var wave_duration := 30.0
var time_remaining := 0.0
var is_active := false

var _spawner: Node2D = null

func init(spawner: Node2D) -> void:
	_spawner = spawner

func start_next_wave() -> void:
	current_wave += 1
	wave_duration = 30.0 + (current_wave - 1) * 8.0

	var interval := maxf(0.4, 2.0 - (current_wave - 1) * 0.12)
	var h_mult := 1.0 + (current_wave - 1) * 0.3
	var s_mult := 1.0 + (current_wave - 1) * 0.08

	_spawner.set_wave_params(interval, h_mult, s_mult)
	_spawner.start()

	time_remaining = wave_duration
	is_active = true
	emit_signal("wave_started", current_wave)

func _process(delta: float) -> void:
	if not is_active:
		return
	time_remaining -= delta
	if time_remaining <= 0.0:
		_end_wave()

func _end_wave() -> void:
	is_active = false
	_spawner.stop()
	emit_signal("wave_ended", current_wave)
