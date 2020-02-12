extends Spatial
class_name BasePlayer

export var blood_color : Color

signal state_changed

onready var head = get_node("head")
onready var camera = get_node("head/camera")
onready var gun = get_node("head/holder/gun")
onready var flash = gun.get_node("flash")
onready var flash_timer = gun.get_node("flash/timer")

var state = {
	dead = false,
	fly = false,
	firing = false
}

func _ready():
	flash_timer.connect("timeout", self, "_on_flash_timeout")

func _physics_process(delta):
	pass

puppet func hit():
	get_node("sounds/impact").play()

puppet func fire():
	gun.get_node("sounds/fire").play()
	flash.visible = true
	flash_timer.start()

func _on_flash_timeout():
	flash.visible = false

puppet func update_pos_rot(pos, rot, h_rot):
	translation = pos
	rotation = rot
	head.rotation = h_rot

puppet func update_state(s, b):
	state[s] = b
	emit_signal("state_changed", s, b)

puppet func create_impact(parent_path : String, pos : Vector3, norm : Vector3):
	var parent = get_node(parent_path)
	var impact = preloader.impact.instance()
	parent.add_child(impact)
	impact.global_transform.origin = pos + norm * 0.01
	impact.global_transform = utils.align_with_normal(impact.global_transform, norm, Vector3.UP)
	impact.rotation = Vector3(impact.rotation.x, impact.rotation.y, rand_range(-1, 1))
	var rand_scale = rand_range(0.75, 1.25)
	impact.scale = Vector3(rand_scale, rand_scale, rand_scale)
	var debris = preloader.debris.instance()
	game.world.add_child(debris)
	debris.color = Color(0.2, 0.2, 0.2)
	debris.global_transform.origin = pos

puppet func create_blood(pos):
	if pos == null:
		pos = global_transform.origin
	var splatter = preloader.splatter.instance()
	splatter.color = blood_color
	game.world.add_child(splatter)
	splatter.global_transform.origin = pos
#	for i in 4:
#		var state = get_world().direct_space_state
#		randomize()
#		var rand_dir = Vector3(pos.x + rand_range(-100, 100), pos.y - 100, pos.z + rand_range(-100, 100))
#		var result = state.intersect_ray(pos, rand_dir)
#		if result:
#			if result.collider is StaticBody:
#				var stain = preloader.stain.instance()
#				stain.color = blood_color
#				game.world.add_child(stain)
#				stain.global_transform.origin = result.position + result.normal * 0.01
#				stain.global_transform = utils.align_with_normal(stain.global_transform, result.normal, Vector3.UP)
#				stain.rotation.y = (stain.translation - pos).x
#				var rand_scale = randi() % 2 + 0.5
#				stain.scale = Vector3(rand_scale, rand_scale, rand_scale)
