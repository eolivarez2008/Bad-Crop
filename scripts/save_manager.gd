extends Node

const SAVE_PATH := "user://save.cfg"

func save_best_score(score: int) -> void:
	var config := ConfigFile.new()
	config.set_value("score", "best", score)
	config.save(SAVE_PATH)

func get_best_score() -> int:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return 0
	return config.get_value("score", "best", 0)
