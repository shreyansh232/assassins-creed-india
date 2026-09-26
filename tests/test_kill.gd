# tests/test_kill.gd
extends SceneTree
func _init():
	var P = load("res://scripts/player.gd").new()
	var G = load("res://scripts/guard.gd").new()
	G.alive = true
	var ok = P.assassinate(G, "unseen", true)
	assert(ok == true and G.alive == false, "unseen unlocked kill should succeed")
	print("KILL_OK")
	quit()
