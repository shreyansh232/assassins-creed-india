# scripts/agra_blockout.gd — Agra MVP post-blockout art pass (procedural CSG + PBR basics).
# ponytail: CSG + StandardMaterial3D only, no custom shaders/textures; real art replaces this.
extends Node3D
var zones := ["fort", "taj", "bazaar", "ghats", "bureau"]
var spots := {
	"fort": Vector3(-16, 0, -10), "taj": Vector3(16, 0, -10),
	"bazaar": Vector3(-8, 0, 6), "ghats": Vector3(8, 0, 8),
	"bureau": Vector3(0, 0, -4),
}
const SANDSTONE := Color(0.62, 0.23, 0.16)
const SAND_DARK := Color(0.45, 0.16, 0.11)
const MARBLE := Color(0.87, 0.84, 0.76)
const WOOD := Color(0.4, 0.26, 0.14)
const SCAFF := Color(0.5, 0.35, 0.2)
const EARTH := Color(0.45, 0.34, 0.22)
const EARTH_DARK := Color(0.36, 0.27, 0.17)
const STONE := Color(0.6, 0.57, 0.5)
const WATER := Color(0.2, 0.45, 0.55, 0.78)
const REED := Color(0.25, 0.45, 0.2)
const HAY := Color(0.8, 0.65, 0.3)
const CREAM := Color(0.85, 0.78, 0.62)

func _mat(c: Color, rough: float = 0.85, metal: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	if c.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _box(parent: Node, n: String, size: Vector3, pos: Vector3, m: Material, col := true) -> CSGBox3D:
	var b := CSGBox3D.new()
	b.name = n
	b.size = size
	b.position = pos
	b.material = m
	b.use_collision = col
	parent.add_child(b)
	return b

func _cyl(parent: Node, n: String, r: float, h: float, pos: Vector3, m: Material) -> CSGCylinder3D:
	var c := CSGCylinder3D.new()
	c.name = n
	c.radius = r
	c.height = h
	c.position = pos
	c.material = m
	c.use_collision = true
	parent.add_child(c)
	return c

func _ball(parent: Node, n: String, r: float, pos: Vector3, m: Material) -> CSGSphere3D:
	var s := CSGSphere3D.new()
	s.name = n
	s.radius = r
	s.position = pos
	s.material = m
	parent.add_child(s)
	return s

func _ready():
	_warm_sky()
	_ground()
	_far_city()
	for z in zones:
		var n = Node3D.new()
		n.name = z
		n.position = spots[z]
		add_child(n)
		match z:
			"fort": _build_fort(n)
			"taj": _build_taj(n)
			"bazaar": _build_bazaar(n)
			"ghats": _build_ghats(n)
			"bureau": _build_bureau(n)
	_dress(get_node("Player"), Color(0.88, 0.84, 0.72), Color(0.75, 0.3, 0.2), Color(0.2, 0.45, 0.45))
	for g in ["Guard1", "Guard2"]:
		_dress(get_node(g), Color(0.6, 0.2, 0.16), Color(0.2, 0.2, 0.25), Color(0.85, 0.7, 0.35))
	print("AGRA_ZONES:", zones.size())
	print("AGRA_ART: fort,taj,bazaar,ghats,bureau fog=1 shadow=1")

func _warm_sky():
	var env := WorldEnvironment.new()
	var e := Environment.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.4, 0.6, 0.82)
	sm.sky_horizon_color = Color(0.96, 0.8, 0.6)
	sm.ground_horizon_color = Color(0.85, 0.68, 0.5)
	sm.ground_bottom_color = Color(0.3, 0.22, 0.15)
	var sky := Sky.new()
	sky.sky_material = sm
	e.background_mode = Environment.BG_SKY
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.7
	e.fog_enabled = true
	e.fog_light_color = Color(0.92, 0.76, 0.6)
	e.fog_density = 0.012
	e.fog_sky_affect = 0.3
	env.environment = e
	env.name = "Sun_env"
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color(1.0, 0.9, 0.78)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-50, -30, 0)
	add_child(sun)

func _ground():
	_box(self, "Ground", Vector3(160, 1, 160), Vector3(0, -0.5, 0), _mat(EARTH, 0.95))
	var dark := _mat(EARTH_DARK, 0.95)
	_box(self, "EarthPatch1", Vector3(14, 0.06, 10), Vector3(-12, 0.03, 2), dark, false)
	_box(self, "EarthPatch2", Vector3(12, 0.06, 12), Vector3(12, 0.03, 0), dark, false)
	var stone := _mat(STONE, 0.9)
	_box(self, "PathNS", Vector3(2.2, 0.08, 40), Vector3(-2, 0.04, -2), stone, false)
	_box(self, "PathEW", Vector3(44, 0.08, 2.2), Vector3(0, 0.04, -3), stone, false)

func _far_city():
	var far := Node3D.new()
	far.name = "FarCity"
	add_child(far)
	var m := _mat(Color(0.55, 0.45, 0.36), 0.9)
	var rng := [Vector3(58, 3, 0), Vector3(-58, 4, 8), Vector3(0, 3.5, 60), Vector3(28, 3, -60),
		Vector3(-35, 5, -56), Vector3(60, 5, 28), Vector3(-60, 3, -25), Vector3(14, 4, 62)]
	for i in rng.size():
		_box(far, "City%d" % i, Vector3(8, rng[i].y * 2.0, 8), Vector3(rng[i].x, rng[i].y, rng[i].z), m, false)

func _build_fort(n: Node3D):
	var wall := _mat(SANDSTONE, 0.9)
	var trim := _mat(SAND_DARK, 0.9)
	var marble := _mat(MARBLE, 0.35)
	_box(n, "WallN", Vector3(12, 4, 0.8), Vector3(0, 2, -5), wall)
	_box(n, "WallS_L", Vector3(4.5, 4, 0.8), Vector3(-3.75, 2, 5), wall)
	_box(n, "WallS_R", Vector3(4.5, 4, 0.8), Vector3(3.75, 2, 5), wall)
	_box(n, "WallE", Vector3(0.8, 4, 10), Vector3(6, 2, 0), wall)
	_box(n, "WallW", Vector3(0.8, 4, 10), Vector3(-6, 2, 0), wall)
	for i in range(-4, 5, 2):
		_box(n, "CrenN%d" % i, Vector3(0.9, 0.6, 0.9), Vector3(i, 4.3, -5), trim, false)
		_box(n, "CrenS%d" % i, Vector3(0.9, 0.6, 0.9), Vector3(i, 4.3, 5), trim, false)
	_cyl(n, "GateL", 1.0, 5.5, Vector3(-2.5, 2.75, 5), trim)
	_cyl(n, "GateR", 1.0, 5.5, Vector3(2.5, 2.75, 5), trim)
	_box(n, "Durbar", Vector3(6, 3, 4), Vector3(0, 1.5, -2.5), marble)
	_ball(n, "DomeF1", 1.2, Vector3(0, 3.6, -2.5), marble)
	_ball(n, "DomeF2", 0.7, Vector3(-2, 3.2, -2.5), marble)
	_ball(n, "DomeF3", 0.7, Vector3(2, 3.2, -2.5), marble)
	var screen := _box(n, "Screen", Vector3(2.4, 2.0, 0.15), Vector3(-4, 1.0, 2), _mat(CREAM, 0.8))
	screen.add_to_group("hiding_spot")
	_hay_cart(n, "HayFort", Vector3(3.5, 0, 2.5))
	_fort_assets(n)

func _fort_assets(n: Node3D):
	const K := "res://assets/kenney/castle/"
	# ponytail: hidden CSG keeps collision, kit models carry the look.
	for c in n.get_children():
		var cn := String(c.name)
		if cn.begins_with("Wall") or cn.begins_with("Gate") or cn.begins_with("Cren"):
			c.visible = false
	for y in [0.0, 2.0]:
		for x in [-5.0, -3.0, -1.0, 1.0, 3.0, 5.0]:
			_prop(n, "WallN%d_%d" % [int(x), int(y)], K + "wall.glb", Vector3(x, y, -5), 0.0, SANDSTONE)
		for z in [-4.0, -2.0, 0.0, 2.0, 4.0]:
			_prop(n, "WallE%d_%d" % [int(z * 10), int(y)], K + "wall.glb", Vector3(6, y, z), 1.5708, SANDSTONE)
			_prop(n, "WallW%d_%d" % [int(z * 10), int(y)], K + "wall.glb", Vector3(-6, y, z), 1.5708, SANDSTONE)
		for x in [-5.0, -3.0, 3.0, 5.0]:
			_prop(n, "WallS%d_%d" % [int(x), int(y)], K + "wall.glb", Vector3(x, y, 5), 0.0, SANDSTONE)
		for cx in [-6.0, 6.0]:
			for cz in [-5.0, 5.0]:
				_prop(n, "Corner%d%d_%d" % [int(cx), int(cz), int(y)], K + "wall-corner.glb", Vector3(cx, y, cz), 0.0, SANDSTONE)
	for gx in [-2.5, 2.5]:
		_prop(n, "GTowerB%d" % int(gx * 10), K + "tower-hexagon-base.glb", Vector3(gx, 0, 5), 0.0, SANDSTONE)
		_prop(n, "GTowerT%d" % int(gx * 10), K + "tower-hexagon-top.glb", Vector3(gx, 2, 5), 0.0, SANDSTONE)
		_ball(n, "GTowerD%d" % int(gx * 10), 0.9, Vector3(gx, 4.4, 5), _mat(MARBLE, 0.35))

func _prop(parent: Node, n: String, path: String, pos: Vector3, rot_y := 0.0, tint := Color.WHITE) -> Node3D:
	var ps: PackedScene = load(path)
	var p = ps.instantiate()
	p.name = n
	p.position = pos
	p.rotation.y = rot_y
	parent.add_child(p)
	if tint != Color.WHITE:
		_tint(p, tint)
	return p

# ponytail: albedo_color multiplies the palette texture, detail preserved.
func _tint(n: Node, c: Color):
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		var mesh := mi.mesh
		if mesh:
			for i in mesh.get_surface_count():
				var m: Material = mi.get_surface_override_material(i)
				if m == null:
					m = mesh.surface_get_material(i)
				if m is StandardMaterial3D:
					var d := (m as StandardMaterial3D).duplicate()
					d.albedo_color = c
					mi.set_surface_override_material(i, d)
	for ch in n.get_children():
		_tint(ch, c)

func _hay_cart(n: Node3D, name: String, pos: Vector3):
	var cart := Node3D.new()
	cart.name = name
	cart.position = pos
	n.add_child(cart)
	_box(cart, "Hay", Vector3(1.6, 0.8, 1.0), Vector3(0, 0.7, 0), _mat(HAY, 0.95))
	var wm := _mat(WOOD, 0.9)
	_cyl(cart, "WheelL", 0.35, 0.1, Vector3(-0.5, 0.35, 0.55), wm).rotation_degrees = Vector3(90, 0, 0)
	_cyl(cart, "WheelR", 0.35, 0.1, Vector3(0.5, 0.35, 0.55), wm).rotation_degrees = Vector3(90, 0, 0)
	cart.add_to_group("hiding_spot")

func _build_taj(n: Node3D):
	var marble := _mat(MARBLE, 0.35)
	var wood := _mat(SCAFF, 0.9)
	_box(n, "Platform", Vector3(10, 0.6, 10), Vector3(0, 0.3, 0), _mat(STONE, 0.9))
	_cyl(n, "Drum", 2.6, 2.2, Vector3(0, 1.7, -1), marble)
	_ball(n, "Dome", 2.6, Vector3(0, 3.6, -1), marble)
	_cyl(n, "Finial", 0.15, 1.6, Vector3(0, 6.2, -1), _mat(Color(0.8, 0.6, 0.25), 0.4, 0.8))
	var scaf := Node3D.new()
	scaf.name = "Scaffold"
	n.add_child(scaf)
	for px in [-3.2, 3.2]:
		for pz in [-3.6, 1.6]:
			_cyl(scaf, "Pole_%d_%d" % [int(px * 10), int(pz * 10)], 0.09, 6.0, Vector3(px, 3.0, pz), wood)
	_box(scaf, "Plank1", Vector3(7.0, 0.12, 0.8), Vector3(0, 2.2, -3.6), wood, false)
	_box(scaf, "Plank2", Vector3(7.0, 0.12, 0.8), Vector3(0, 4.2, -3.6), wood, false)
	_box(scaf, "Plank3", Vector3(0.8, 0.12, 5.6), Vector3(3.2, 3.2, -1), wood, false)
	var ramp := _box(n, "Ramp", Vector3(1.6, 0.25, 7.0), Vector3(-4.5, 1.2, 1.5), wood)
	ramp.rotation_degrees = Vector3(-18, 0, 0)
	_cyl(n, "Crane", 0.15, 8.0, Vector3(4.5, 4.0, 2.5), wood)
	var arm := _box(n, "CraneArm", Vector3(0.2, 0.2, 4.5), Vector3(4.5, 7.6, 0.8), wood, false)
	arm.add_to_group("rooftop")
	_cyl(n, "Rope", 0.03, 2.5, Vector3(4.5, 6.2, -1.0), _mat(Color(0.7, 0.6, 0.45), 0.9))
	_box(n, "Block", Vector3(0.8, 0.8, 0.8), Vector3(4.5, 4.6, -1.0), marble)

func _build_bazaar(n: Node3D):
	_stall(n, "Stall1", Vector3(-3, 0, -1), "res://assets/kenney/stall-red.glb")
	_stall(n, "Stall2", Vector3(3, 0, -1), "res://assets/kenney/stall-green.glb")
	_prop(n, "Cart", "res://assets/kenney/cart.glb", Vector3(5.2, 0, -2.5), -0.5)
	_prop(n, "Lantern1", "res://assets/kenney/lantern.glb", Vector3(-1.5, 0, 1.8))
	_prop(n, "Lantern2", "res://assets/kenney/lantern.glb", Vector3(1.5, 0, 1.8))
	_box(n, "House1", Vector3(4, 3.2, 4), Vector3(-4.5, 1.6, 3.5), _mat(Color(0.72, 0.55, 0.38), 0.9))
	_box(n, "Roof1", Vector3(4.4, 0.3, 4.4), Vector3(-4.5, 3.35, 3.5), _mat(SAND_DARK, 0.9)).add_to_group("rooftop")
	_box(n, "House2", Vector3(4, 4.2, 4), Vector3(3.5, 2.1, 4), _mat(Color(0.68, 0.5, 0.34), 0.9))
	_box(n, "Roof2", Vector3(4.4, 0.3, 4.4), Vector3(3.5, 4.35, 4), _mat(SAND_DARK, 0.9)).add_to_group("rooftop")
	var tent := _box(n, "Tent", Vector3(2.2, 0.15, 2.2), Vector3(0, 1.5, 3), _mat(Color(0.55, 0.45, 0.3), 0.9))
	tent.rotation_degrees = Vector3(0, 0, 12)
	tent.add_to_group("hiding_spot")
	_hay_cart(n, "HayBazaar", Vector3(0.5, 0, -3.5))
	_crowd(n, Vector3(0, 0, 0.5))

func _stall(n: Node3D, name: String, pos: Vector3, asset: String):
	var s := Node3D.new()
	s.name = name
	s.position = pos
	n.add_child(s)
	_prop(s, "Asset", asset, Vector3.ZERO)
	# ponytail: hidden CSG keeps collision, asset carries the look.
	_box(s, "Counter", Vector3(2.2, 1.8, 1.4), Vector3(0, 0.9, 0), _mat(WOOD, 0.9)).visible = false
	_prop(s, "Bench", "res://assets/kenney/stall-bench.glb", Vector3(0, 0, 1.6))

func _crowd(n: Node3D, pos: Vector3):
	var c := Node3D.new()
	c.name = "Crowd"
	c.position = pos
	n.add_child(c)
	var kurtas := [Color(0.8, 0.75, 0.6), Color(0.5, 0.3, 0.35), Color(0.35, 0.45, 0.5), Color(0.7, 0.55, 0.3)]
	for i in 4:
		var f := Node3D.new()
		f.name = "Person%d" % i
		f.position = Vector3(-1.2 + i * 0.8, 0, (i % 2) * 0.8 - 0.4)
		c.add_child(f)
		var torso := MeshInstance3D.new()
		var cap := CapsuleMesh.new()
		cap.radius = 0.28
		cap.height = 1.4
		torso.mesh = cap
		torso.material_override = _mat(kurtas[i], 0.9)
		torso.position = Vector3(0, 0.7, 0)
		f.add_child(torso)
		var head := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.16
		sm.height = 0.32
		head.mesh = sm
		head.material_override = _mat(Color(0.72, 0.52, 0.36), 0.8)
		head.position = Vector3(0, 1.5, 0)
		f.add_child(head)
	c.add_to_group("blend_zone")

func _build_ghats(n: Node3D):
	var stone := _mat(STONE, 0.9)
	var steps := Node3D.new()
	steps.name = "Steps"
	n.add_child(steps)
	for i in 4:
		_box(steps, "Step%d" % i, Vector3(8, 0.3, 1.2), Vector3(0, 0.5 - i * 0.35, 2.0 + i * 1.1), stone)
	_box(n, "Water", Vector3(14, 0.2, 8), Vector3(0, -0.6, 8.5), _mat(WATER, 0.15), false)
	var reeds := Node3D.new()
	reeds.name = "Reeds"
	reeds.position = Vector3(-4.5, 0, 5.5)
	n.add_child(reeds)
	var rm := _mat(REED, 0.9)
	for i in 6:
		_cyl(reeds, "Reed%d" % i, 0.05, 1.0 + (i % 3) * 0.3, Vector3((i % 3) * 0.5, 0.5, (i / 3) * 0.6), rm)
	reeds.add_to_group("hiding_spot")

func _build_bureau(n: Node3D):
	var wall := _mat(Color(0.74, 0.6, 0.42), 0.9)
	_box(n, "HaveliN", Vector3(8, 3, 0.6), Vector3(0, 1.5, -3), wall)
	_box(n, "HaveliW", Vector3(0.6, 3, 7), Vector3(-4, 1.5, 0), wall)
	_box(n, "HaveliE", Vector3(0.6, 3, 7), Vector3(4, 1.5, 0), wall)
	_box(n, "RoofB", Vector3(8.6, 0.3, 7.6), Vector3(0, 3.15, 0), _mat(SAND_DARK, 0.9), false)
	_box(n, "Table", Vector3(1.8, 0.75, 0.9), Vector3(0, 0.38, -1), _mat(WOOD, 0.8))
	_box(n, "Paper", Vector3(0.7, 0.03, 0.5), Vector3(-0.3, 0.78, -1), _mat(Color(0.92, 0.88, 0.76), 0.6), false)
	var lamp_mat := StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.75, 0.4)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.6, 0.25)
	lamp_mat.emission_energy_multiplier = 1.5
	_ball(n, "Lamp", 0.15, Vector3(0.6, 1.0, -1), lamp_mat)

func _dress(body: CharacterBody3D, torso_c: Color, turban_c: Color, sash_c: Color) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "Body"
	var cap := CapsuleMesh.new()
	cap.radius = 0.4
	cap.height = 1.8
	mesh.mesh = cap
	mesh.material_override = _mat(torso_c, 0.9)
	mesh.position = Vector3(0, 0.9, 0)
	body.add_child(mesh)
	var turban := MeshInstance3D.new()
	turban.name = "Turban"
	var tm := SphereMesh.new()
	tm.radius = 0.24
	tm.height = 0.34
	turban.mesh = tm
	turban.material_override = _mat(turban_c, 0.85)
	turban.position = Vector3(0, 1.82, 0)
	body.add_child(turban)
	var sash := MeshInstance3D.new()
	sash.name = "Sash"
	var bm := BoxMesh.new()
	bm.size = Vector3(0.86, 0.22, 0.86)
	sash.mesh = bm
	sash.material_override = _mat(sash_c, 0.85)
	sash.position = Vector3(0, 1.0, 0)
	body.add_child(sash)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	body.add_child(col)
