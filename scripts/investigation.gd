# scripts/investigation.gd
extends Node
class_name Investigation
var clues: Array = []
func add_clue(id: String):
	if not clues.has(id): clues.append(id)
func is_target_unlocked() -> bool:
	return clues.size() >= 3
