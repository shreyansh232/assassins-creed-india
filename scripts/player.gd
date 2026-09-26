# scripts/player.gd
extends CharacterBody3D
class_name StealthPlayer
var walk_speed_stand := 4.0
var walk_speed_crouched := 2.0
var is_crouched := false
var disguise := "none"
func set_crouch(v: bool): is_crouched = v
func whistle(): pass
func throw_coin(_pos: Vector3): pass
func _physics_process(_d):
	velocity = Vector3.ZERO
	move_and_slide()
func assassinate(g, state: String, unlocked: bool) -> bool:
	if state == "unseen" and unlocked and g.alive:
		g.alive = false
		return true
	return false
func smoke_escape():
	pass
