extends Position3D

var mouse_relative_x = 0.0
var mouse_relative_y = 0.0
const EASING = 8

func _process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.x = lerp(rotation_degrees.x, mouse_relative_y / 4, EASING * delta)
		rotation_degrees.y = lerp(rotation_degrees.y, mouse_relative_x / 4, EASING * delta)
		mouse_relative_x = 0
		mouse_relative_y = 0

func _input(event):
	if event is InputEventMouseMotion:
		mouse_relative_x = event.relative.x
		mouse_relative_y = event.relative.y
