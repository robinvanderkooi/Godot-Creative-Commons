extends Camera3D

var time = 0.0
var radius = 5.0

func _process(delta: float) -> void:
	time += delta
	position = Vector3((sin(time)*radius) +20.0, 10.0, (cos(time)*radius) +20.0)
	pass
