extends CanvasLayer

@onready var best_score_label := $Panel/Layout/BestScore
@onready var play_button := $Panel/Layout/PlayButton

func _ready() -> void:
	best_score_label.text = "Meilleur score : " + str(SaveManager.get_best_score())
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
