# scripts/agra_blockout.gd
extends Node3D
var zones := ["fort", "taj", "bazaar", "ghats", "bureau"]
func _ready():
	for z in zones:
		var n = Node3D.new()
		n.name = z
		add_child(n)
	print("AGRA_ZONES:", zones.size())
