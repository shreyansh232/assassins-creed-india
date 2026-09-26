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
func _physics_process(d):
	var iv := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var speed := walk_speed_crouched if is_crouched else walk_speed_stand
	velocity.x = iv.x * speed
	velocity.z = iv.y * speed
	if is_on_floor():
		if velocity.y < 0.0: velocity.y = 0.0
	else:
		velocity.y -= 20.0 * d
	move_and_slide()
func assassinate(g, state: String, unlocked: bool) -> bool:
	if state == "unseen" and unlocked and g.alive:
		g.alive = false
		return true
	return false
func smoke_escape():
	pass
