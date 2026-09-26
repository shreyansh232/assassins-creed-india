# scripts/capture_shots.gd — dumps e2e/shots/stats.json + viewport PNGs for the Playwright report.
# Run WITH a display (no --headless) so Metal renders: godot --path . --resolution 1280x720 -s scripts/capture_shots.gd
extends SceneTree
var agra = null
var cam: Camera3D = null
var frame := 0
var views := [
	{"shot": "overview", "pos": Vector3(0, 30, 34), "look": Vector3(0, 0, -4)},
	{"shot": "fort", "pos": Vector3(-16, 9, 6), "look": Vector3(-16, 1, -10)},
	{"shot": "taj_ghats", "pos": Vector3(12, 8, 12), "look": Vector3(12, 1, -4)},
	{"shot": "bazaar", "pos": Vector3(-8, 5, -4), "look": Vector3(-8, 1, 7)},
	{"shot": "ghats", "pos": Vector3(8, 3, 3), "look": Vector3(8, 0, 13)},
]
var taken := {}
func _initialize():
	root.size = Vector2i(1280, 720)
	var ps: PackedScene = load("res://scenes/agra.tscn")
	agra = ps.instantiate()
	root.add_child(agra)
	cam = Camera3D.new()
	cam.name = "ShotCam"
	cam.current = true
	cam.fov = 55.0
	root.add_child(cam)
	DirAccess.make_dir_recursive_absolute("res://e2e/shots")
func _process(_d) -> bool:
	frame += 1
	if frame < 15:
		return false
	var idx := (frame - 15) / 10
	if idx < views.size():
		var v = views[idx]
		if not taken.has(v["shot"]):
			cam.position = v["pos"]
			cam.look_at(v["look"])
			taken[v["shot"]] = frame + 4
		if taken[v["shot"]] == frame:
			_shot(v["shot"])
		return false
	_stats()
	print("CAPTURE_DONE")
	quit()
	return true
func _shot(n: String):
	await process_frame
	await process_frame
	var img := root.get_texture().get_image()
	img.save_png("res://e2e/shots/%s.png" % n)
	print("SHOT:", n)
func _stats():
	var d := {"zones": {}, "flags": {}, "groups": {}, "node_count": 0}
	for z in ["fort", "taj", "bazaar", "ghats", "bureau"]:
		d["zones"][z] = _props(agra.get_node_or_null(z))
	var sun = agra.get_node_or_null("Sun")
	var wenv = agra.get_node_or_null("Sun_env")
	d["flags"]["shadow"] = sun != null and sun.shadow_enabled
	d["flags"]["fog"] = wenv != null and wenv.environment.fog_enabled
	d["flags"]["sky"] = wenv != null and wenv.environment.background_mode == Environment.BG_SKY
	for g in ["hiding_spot", "rooftop", "blend_zone"]:
		d["groups"][g] = get_nodes_in_group(g).size()
	d["node_count"] = _count(agra)
	var f := FileAccess.open("res://e2e/shots/stats.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(d, "\t"))
	f.close()
func _props(n: Node) -> Array:
	var out := []
	if n == null:
		return out
	for c in n.get_children():
		var e := {"name": String(c.name), "pos": _v(_gpos(c)), "kids": []}
		if c is CSGBox3D:
			e["size"] = _v(c.size)
			e["color"] = _c(c.material)
		elif c is CSGSphere3D:
			e["size"] = [c.radius * 2.0, c.radius * 2.0, c.radius * 2.0]
			e["color"] = _c(c.material)
		elif c is CSGCylinder3D:
			e["size"] = [c.radius * 2.0, c.height, c.radius * 2.0]
			e["color"] = _c(c.material)
		for g in c.get_children():
			if g is CSGBox3D or g is CSGSphere3D or g is CSGCylinder3D:
				e["kids"].append(String(g.name))
		out.append(e)
	return out
func _gpos(c: Node) -> Vector3:
	return c.global_position if c is Node3D else Vector3.ZERO
func _v(v: Vector3) -> Array:
	return [snappedf(v.x, 0.01), snappedf(v.y, 0.01), snappedf(v.z, 0.01)]
func _c(m: Material) -> Array:
	if m is StandardMaterial3D:
		var a: Color = m.albedo_color
		return [a.r, a.g, a.b]
	return [0.5, 0.5, 0.5]
func _count(n: Node) -> int:
	var t := 1
	for c in n.get_children():
		t += _count(c)
	return t
