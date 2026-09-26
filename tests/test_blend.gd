# tests/test_blend.gd
extends SceneTree
func _init():
	var B = load("res://scripts/crowd_blend.gd").new()
	assert(B.can_enter("fort", "noble", false) == true, "noble enters fort")
	assert(B.can_enter("fort", "mazdoor", false) == false, "mazdoor blocked fort")
	assert(B.can_enter("fort", "mazdoor", true) == true, "farman overrides")
	assert(B.can_enter("taj", "mazdoor", false) == true, "mazdoor enters taj")
	print("BLEND_OK")
	quit()
