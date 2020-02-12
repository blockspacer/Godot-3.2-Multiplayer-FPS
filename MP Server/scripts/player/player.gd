extends BasePlayer
class_name Player

onready var timer_fire = get_node("timers/fire")
var can_fire : bool = true

func _ready():
	timer_fire.connect("timeout", self, "_on_fire_timeout")

func process_commands(delta):
	.process_commands(delta)
	# Firing
	if cmd.primary_fire and !state.dead and can_fire:
		fire_gun()
	
func _on_fire_timeout():
	can_fire = true

func fire_gun():
	rpc_unreliable("fire")
	can_fire = false
	var screen_center = get_viewport().size / 2
	var state = get_world().direct_space_state
	var from = camera.project_ray_origin(screen_center)
	var to = from + camera.project_ray_normal(screen_center) * 1000
	var result = state.intersect_ray(from, to, [self], 1, true, false)
	if result:
		var dir = (result.position - global_transform.origin).normalized()
		if result.collider is PhysicalBone:
			result.collider.apply_impulse(result.position, dir / 5)
		if result.collider is RigidBody:
			result.collider.apply_impulse(result.position + result.normal * 0.01, dir / 5)
			rpc_unreliable("create_impact", result.collider.get_path(), result.position, result.normal)
		if result.collider is StaticBody:
			rpc_unreliable("create_impact", game.world.get_path(), result.position, result.normal)
		if result.collider is BasePlayer:
			result.collider.hit(10, self, result)
			result.collider.vel = dir * 10
			#rpc_unreliable("create_impact", result.collider.get_path(), result.position, result.normal)
	timer_fire.start()
