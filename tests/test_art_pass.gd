# tests/test_art_pass.gd — Issue #1: Agra reads as 1656 Agra, stealth reads hold.
extends SceneTree
var agra = null
func _initialize():
	var ps: PackedScene = load("res://scenes/agra.tscn")
	agra = ps.instantiate()
	root.add_child(agra)
func _process(_d) -> bool:
	for z in ["fort", "taj", "bazaar", "ghats", "bureau"]:
		assert(agra.get_node_or_null(z) != null, z + " zone missing")
	var sun = agra.get_node_or_null("Sun")
	assert(sun != null and sun.shadow_enabled, "sun shadows missing")
	var wenv = agra.get_node_or_null("Sun_env")
	assert(wenv != null and wenv.environment.fog_enabled, "distance fog missing")
	assert(wenv.environment.background_mode == Environment.BG_SKY, "warm sky missing")
	var wall = agra.get_node_or_null("fort/WallN")
	assert(wall != null and wall.material.albedo_color.r > 0.5 and wall.material.albedo_color.g < 0.4, "fort not red sandstone")
	assert(agra.get_node_or_null("fort/GateL") != null, "fort gate missing")
	assert(agra.get_node_or_null("fort/Durbar") != null, "durbar massing missing")
	var dome = agra.get_node_or_null("taj/Dome")
	assert(dome != null and dome.material.albedo_color.r > 0.8, "taj dome not marble white")
	assert(agra.get_node_or_null("taj/Scaffold") != null, "taj scaffolds missing")
	assert(agra.get_node_or_null("taj/Crane") != null, "taj crane missing")
	assert(agra.get_node_or_null("bazaar/Stall1/Asset") != null, "bazaar stall model missing")
	assert(agra.get_node_or_null("bazaar/Crowd") != null, "crowd blend missing")
	var water = agra.get_node_or_null("ghats/Water")
	assert(water != null and water.material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA, "ghat water missing")
	assert(agra.get_node_or_null("ghats/Reeds") != null, "ghat reeds missing")
	assert(agra.get_node_or_null("bureau/Table") != null, "contract table missing")
	assert(agra.get_node_or_null("Player/Body") != null, "player mesh missing")
	assert(agra.get_node_or_null("Player/Turban") != null, "period silhouette missing")
	assert(get_nodes_in_group("hiding_spot").size() >= 5, "hiding spots not obvious")
	assert(get_nodes_in_group("rooftop").size() >= 3, "rooftops not obvious")
	assert(get_nodes_in_group("blend_zone").size() >= 1, "blend zones not obvious")
	print("ART_OK")
	quit()
	return true
