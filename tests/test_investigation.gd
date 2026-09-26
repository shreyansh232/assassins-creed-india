# tests/test_investigation.gd
extends SceneTree
func _init():
	var I = load("res://scripts/investigation.gd").new()
	I.add_clue("fort")
	I.add_clue("bazaar")
	assert(I.is_target_unlocked() == false, "2 clues not enough")
	I.add_clue("taj")
	assert(I.is_target_unlocked() == true, "3 clues unlocks")
	print("INVEST_OK")
	quit()
