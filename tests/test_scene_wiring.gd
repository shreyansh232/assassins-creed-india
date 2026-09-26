# tests/test_scene_wiring.gd
extends SceneTree
func _init():
	var ps: PackedScene = load("res://scenes/agra.tscn")
	assert(ps != null, "agra scene missing")
	var agra = ps.instantiate()
	assert(agra.get_node_or_null("Player") != null, "Player missing")
	assert(agra.get_node_or_null("Player/SpringArm3D/Camera3D") != null, "camera missing")
	var guards := 0
	for c in agra.get_children():
		if String(c.name).begins_with("Guard"):
			guards += 1
	assert(guards >= 2, "need 2 guards")
	print("SCENE_OK")
	quit()
