# tests/test_detection.gd
extends SceneTree
func _init():
	var D = load("res://scripts/detection.gd").new()
	assert(D.get_state(30.0, false, false) == "unseen", "far should be unseen")
	assert(D.get_state(5.0, false, false) == "hunted", "close standing should be hunted")
	assert(D.get_state(5.0, true, true) == "unseen", "hiding crouched should be unseen")
	print("DETECT_OK")
	quit()
