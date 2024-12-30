extends Label

var time = 0.0
var frame = 0
var halfFrames = 0

func _process(delta: float) -> void:
	var halfTime = 1.0
	var fullTime = 2.0
	time += delta
	frame += 1
	if time > halfTime and halfFrames == 0:
		halfFrames = frame
	if time > fullTime:
		time -= halfTime
		frame -= halfFrames
		halfFrames = 0
	text = " FPS: " + str( int(float(frame) / time) )
	#text = " FPS: " + str( int(Engine.get_frames_per_second()) ) # turns out I did a frame rate for nothing. But it works!!!

	pass
