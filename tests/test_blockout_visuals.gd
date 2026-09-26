# tests/test_blockout_visuals.gd
extends SceneTree
var agra = null
func _initialize():
	var ps: PackedScene = load("res://scenes/agra.tscn")
	agra = ps.instantiate()
	root.add_child(agra)
func _process(_d) -> bool:
	assert(agra.get_node_or_null("Ground") != null, "Ground missing")
	assert(agra.get_node_or_null("Player/Body") != null, "player mesh missing")
	var lit := false
	for c in agra.get_children():
		if c is DirectionalLight3D or c is WorldEnvironment:
			lit = true
	assert(lit, "no lights")
	print("VISUALS_OK")
	quit()
	return true
