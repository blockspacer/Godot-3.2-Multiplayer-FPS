extends Spatial

export var color : Color

func _ready():
	$particles.mesh.surface_get_material(0).albedo_color = color
	$particles.emitting = true

func _physics_process(delta):
	if !$particles.emitting:
		queue_free()
