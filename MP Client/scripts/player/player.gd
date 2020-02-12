extends BasePlayer
class_name Player

var MOUSE_SENSITIVITY = 0.05
var INVERSION = -1

var score

func _ready():
	connect("state_changed", self, "_on_state_changed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)

func _on_state_changed(s, b):
	match s:
		"dead":
			gun.visible = !state[s]
			if state[s]:
				game.main_scene.display_message("You are dead! Respawning...")

puppet func update_score(value):
	score = value
	get_node("hud/score").text = "Score: " + str(score)

func process_input(delta):
	# Input
	if Input.is_action_pressed("move_forward"):
		rpc_unreliable_id(1, "execute_command", "move_forward", true)
	else:
		rpc_unreliable_id(1, "execute_command", "move_forward", false)
	if Input.is_action_pressed("move_backward"):
		rpc_unreliable_id(1, "execute_command", "move_backward", true)
	else:
		rpc_unreliable_id(1, "execute_command", "move_backward", false)
	if Input.is_action_pressed("move_left"):
		rpc_unreliable_id(1, "execute_command", "move_left", true)
	else:
		rpc_unreliable_id(1, "execute_command", "move_left", false)
	if Input.is_action_pressed("move_right"):
		rpc_unreliable_id(1, "execute_command", "move_right", true)
	else:
		rpc_unreliable_id(1, "execute_command", "move_right", false)
	if Input.is_action_pressed("move_jump"):
		rpc_unreliable_id(1, "execute_command", "move_jump", true)
	else:
		rpc_unreliable_id(1, "execute_command", "move_jump", false)
	if Input.is_action_pressed("primary_fire"):
		rpc_unreliable_id(1, "execute_command", "primary_fire", true)
	else:
		rpc_unreliable_id(1, "execute_command", "primary_fire", false)
	
	# Capturing/freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rpc_unreliable_id(1, "update_rotation", event.relative.x * MOUSE_SENSITIVITY * INVERSION, event.relative.y * MOUSE_SENSITIVITY * INVERSION)
