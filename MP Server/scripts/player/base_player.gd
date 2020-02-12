extends KinematicBody
class_name BasePlayer

const MAX_HEALTH = 100
var health setget set_health

const GRAVITY = -24.8
const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCEL = 5
const DEACCEL = 10
const MAX_FLY_SPEED = 10
const FLY_ACCEL = 5
const MAX_SLOPE_ANGLE = 40

var vel = Vector3()
var pvel = Vector3()
var dir = Vector3()

var camera
var head

var state = {
	dead = false,
	flying = false,
	firing = false
}

var cmd = {
	move_forward = false,
	move_backward = false,
	move_left = false,
	move_right = false,
	move_jump = false,
	primary_fire = false
}

var score : int setget set_score, get_score
var last_damage_dealer

func _ready():
	camera = get_node("head/camera")
	head = get_node("head")
	set_health(MAX_HEALTH)
	$timers/respawn.connect("timeout", self, "_on_respawn_timeout")

func _physics_process(delta):
	process_commands(delta)
	process_movement(delta)
	rpc_unreliable("update_pos_rot", translation, rotation, head.rotation)

func process_commands(delta):
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	if cmd.move_forward:
		input_movement_vector.y += 1
	if cmd.move_backward:
		input_movement_vector.y -= 1
	if cmd.move_left:
		input_movement_vector.x -= 1
	if cmd.move_right:
		input_movement_vector.x += 1
	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# Jumping
	if is_on_floor() and !state.flying:
		if cmd.move_jump:
			vel.y = JUMP_SPEED

func process_movement(delta):
	if !state.flying:
		dir.y = 0
		dir = dir.normalized()
		vel.y += delta * GRAVITY
		var hvel = vel
		hvel.y = 0
		var target = dir
		target *= MAX_SPEED
		var accel
		if dir.dot(hvel) > 0:
			accel = ACCEL
		else:
			accel = DEACCEL
		hvel = hvel.linear_interpolate(target, accel * delta)
		vel.x = hvel.x
		vel.z = hvel.z
		vel = move_and_slide(vel, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	else:
		dir = dir.normalized()
		var target = dir
		target *= MAX_FLY_SPEED
		vel = vel.linear_interpolate(target, FLY_ACCEL * delta)
		vel = move_and_slide(vel)
	
	# Fall damage
	if vel.y - pvel.y >= 30:
		hit(20, null, null)
	pvel = vel

func set_health(value):
	health = clamp(value, 0, MAX_HEALTH)
	if health <= 0 and !state.dead:
		die()

func hit(damage, dealer, result):
	set_health(health - damage)
	if dealer:
		last_damage_dealer = dealer
		if result:
			rpc("hit")
			rpc_unreliable("create_blood", result.position)
		else:
			rpc("hit")
			rpc_unreliable("create_blood")

func die():
	if !state.dead:
		if last_damage_dealer:
			last_damage_dealer.set_score(last_damage_dealer.get_score() + 1)
		set_state("dead", true)
		set_state("flying", true)
		vel = Vector3.ZERO
		$shape.disabled = true
		collision_layer = 2
		$timers/respawn.start()
		
func respawn():
	if state.dead:
		set_state("flying", false)
		set_state("dead", false)
		set_health(MAX_HEALTH)
		vel = Vector3.ZERO
		$shape.disabled = false
		collision_layer = 1
		global_transform.origin = game.main_scene.spawn_points[randi() % game.main_scene.spawn_points.size()].global_transform.origin

func _on_respawn_timeout():
	respawn()

func set_state(s : String, b : bool):
	state[s] = b
	rpc("update_state", s, b)

func set_score(value):
	score = value
	rpc("update_score", score)
	
func get_score():
	return score

remote func update_rotation(x : float, y : float):
	if int(name) == get_tree().get_rpc_sender_id():
		head.rotate_x(deg2rad(y))
		rotate_y(deg2rad(x))
		var camera_rot = head.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		head.rotation_degrees = camera_rot

remote func execute_command(a, b):
	if int(name) == get_tree().get_rpc_sender_id():
		cmd[a] = b
