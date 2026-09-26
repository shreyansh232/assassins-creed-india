# scripts/player.gd
extends CharacterBody3D
class_name StealthPlayer
var walk_speed_stand := 4.0
var walk_speed_crouched := 2.0
var is_crouched := false
var disguise := "none"
var mouse_sens := 0.003
var arm: SpringArm3D
func _ready():
	arm = get_node_or_null("SpringArm3D")
	if arm:
		arm.rotation.x = -0.25
func _unhandled_input(e):
	if e is InputEventMouseButton and e.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif e is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-e.relative.x * mouse_sens)
		if arm:
			arm.rotation.x = clampf(arm.rotation.x - e.relative.y * mouse_sens, -1.2, 0.5)
	elif e.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func set_crouch(v: bool): is_crouched = v
func whistle(): pass
func throw_coin(_pos: Vector3): pass
func _physics_process(d):
	var iv := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var speed := walk_speed_crouched if is_crouched else walk_speed_stand
	var dir := global_transform.basis * Vector3(iv.x, 0.0, iv.y)
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
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
