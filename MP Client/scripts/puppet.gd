extends BasePlayer
class_name Puppet

func _ready():
	connect("state_changed", self, "_on_state_changed")

func _on_state_changed(s, b):
	match s:
		"dead":
			visible = !state[s]
