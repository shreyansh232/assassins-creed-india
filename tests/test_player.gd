# tests/test_player.gd
extends SceneTree
func _init():
	var p = load("res://scripts/player.gd").new()
	p.is_crouched = false
	p.set_crouch(true)
	assert(p.is_crouched == true, "crouch failed")
	assert(p.walk_speed_crouched < p.walk_speed_stand, "crouch not slower")
	print("PLAYER_OK")
	quit()
