extends Node

func _ready():
	pass

puppet func update_pos_rot(n, pos : Vector3, rot : Vector3):
	get_node(n).translation = pos
	get_node(n).rotation = rot
