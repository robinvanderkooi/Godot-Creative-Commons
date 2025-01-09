extends RigidBody3D

var printy = false
var time = 0.0
var last_second = 0

func _process(_delta: float) -> void:
	time += _delta
	if int(time) != last_second:
		last_second = int(time)
		#triggered
		#print(str(last_second) + self.name + " " + str(position))
		pass
	pass
