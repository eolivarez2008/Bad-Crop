extends CanvasLayer

const ICON_PEPPER: String = "\uf816"
const ICON_WAVE: String = "\uf091"
const ICON_CLOCK: String = "\uf017"

@onready var health_bar: ProgressBar = $HealthBar
@onready var pepper_label: Label = $PepperCount
@onready var wave_label: Label = $WaveContainer/WaveLabel
@onready var wave_timer: Label = $WaveContainer/WaveTimer
@onready var level_bar: ProgressBar = $SpicyContainer/LevelBar
@onready var level_label: Label = $SpicyContainer/LevelLabel

func update_health(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func update_peppers(amount: int) -> void:
	pepper_label.text = ICON_PEPPER + " " + str(amount)

func update_wave(wave_number: int) -> void:
	wave_label.text = ICON_WAVE + " Vague " + str(wave_number)

func update_timer(seconds_remaining: float) -> void:
	wave_timer.text = ICON_CLOCK + " " + str(int(ceil(seconds_remaining))) + "s"

func update_spicy(level: int, current_xp: int, needed_xp: int) -> void:
	if not is_instance_valid(level_bar):
		return
	level_bar.max_value = needed_xp
	level_bar.value = current_xp
	level_label.text = "LVL " + str(level)

func on_level_up(level: int) -> void:
	if not is_instance_valid(level_bar):
		return
	level_label.text = "LVL " + str(level)
	var tween := create_tween()
	tween.tween_property(level_bar, "modulate", Color(2.0, 1.5, 0.0), 0.1)
	tween.tween_property(level_bar, "modulate", Color.WHITE, 0.4)
