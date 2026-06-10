extends CanvasLayer

@onready var wave_label := $Panel/Layout/WaveLabel
@onready var best_score_label := $Panel/Layout/BestScore
@onready var menu_button := $Panel/Layout/MenuButton

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_pressed)

func show_game_over(wave_reached: int) -> void:
	var best := SaveManager.get_best_score()
	if wave_reached > best:
		SaveManager.save_best_score(wave_reached)
		best = wave_reached
	wave_label.text = "Vague atteinte : " + str(wave_reached)
	best_score_label.text = "Meilleur score : " + str(best)
	visible = true
	get_tree().paused = true

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
