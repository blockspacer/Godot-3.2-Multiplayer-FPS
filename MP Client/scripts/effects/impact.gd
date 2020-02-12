extends Spatial

export var color : Color

func _ready():
	$mesh.mesh.surface_get_material(0).albedo_color = color
	yield(get_tree().create_timer(10), "timeout")
	queue_free()
