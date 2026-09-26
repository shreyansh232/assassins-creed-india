# scripts/agra_blockout.gd
extends Node3D
var zones := ["fort", "taj", "bazaar", "ghats", "bureau"]
var spots := {
	"fort": Vector3(-16, 0, -10), "taj": Vector3(16, 0, -10),
	"bazaar": Vector3(-8, 0, 6), "ghats": Vector3(8, 0, 8),
	"bureau": Vector3(0, 0, -4),
}
var tints := {
	"fort": Color(0.7, 0.3, 0.25), "taj": Color(0.85, 0.82, 0.75),
	"bazaar": Color(0.75, 0.6, 0.3), "ghats": Color(0.3, 0.55, 0.7),
	"bureau": Color(0.45, 0.6, 0.4),
}
func _ready():
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.08, 0.07, 0.09)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.6, 0.6, 0.65)
	e.ambient_light_energy = 0.8
	env.environment = e
	env.name = "Sun_env"
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-50, -30, 0)
	add_child(sun)
	var ground := CSGBox3D.new()
	ground.name = "Ground"
	ground.size = Vector3(60, 1, 60)
	ground.position = Vector3(0, -0.5, 0)
	ground.use_collision = true
	add_child(ground)
	for z in zones:
		var n = Node3D.new()
		n.name = z
		n.position = spots[z]
		add_child(n)
		var box := CSGBox3D.new()
		box.size = Vector3(4, 3, 4)
		box.position = Vector3(0, 1.5, 0)
		box.use_collision = true
		box.material = _mat(tints[z])
		n.add_child(box)
	_dress(get_node("Player"), Color(0.35, 0.7, 0.35))
	for g in ["Guard1", "Guard2"]:
		_dress(get_node(g), Color(0.75, 0.3, 0.3))
	print("AGRA_ZONES:", zones.size())
func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	return m
func _dress(body: CharacterBody3D, c: Color) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "Body"
	var cap := CapsuleMesh.new()
	cap.radius = 0.4
	cap.height = 1.8
	mesh.mesh = cap
	mesh.material_override = _mat(c)
	mesh.position = Vector3(0, 0.9, 0)
	body.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	col.shape = shape
	col.position = Vector3(0, 0.9, 0)
	body.add_child(col)
