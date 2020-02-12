extends Node

const PORT = 27015
const MAX_PLAYERS = 32

onready var message = $ui/message
onready var world = $world

var spawn_points = []

func _ready():
	var server = NetworkedMultiplayerENet.new()
	server.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(server)
	
	get_tree().connect("network_peer_connected", self, "_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	
	create_map()

func _client_connected(id):
	message.text = "Client " + str(id) + " connected."
	var player = load("res://scenes/player/player.tscn").instance()
	player.set_name(str(id))
	world.get_node("players").add_child(player)
	player.global_transform.origin = spawn_points[randi() % spawn_points.size()].global_transform.origin

func _client_disconnected(id):
	message.text = "Client " + str(id) + " disconnected."
	for p in world.get_node("players").get_children():
		if int(p.name) == id:
			world.get_node("players").remove_child(p)
			p.queue_free()

func create_map():
	var map = load("res://scenes/map.tscn").instance()
	world.add_child(map)
	spawn_points = map.get_node("spawn_points").get_children()
