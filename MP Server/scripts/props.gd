extends Node

func _ready():
	pass

func _physics_process(delta):
	for n in get_children():
		if n is RigidBody:
			rpc_unreliable("update_pos_rot", n.name, n.translation, n.rotation)
