extends Camera3D

var time = 0.0
var radius = 5.0

var speed = 10.0
var run_speed = 50.0

func _process(delta: float) -> void:
	time += delta
	#position = Vector3((sin(time)*radius) +20.0, 10.0, (cos(time)*radius) +20.0)
	var left = 0
	var forward = 0
	var up = 0
	var multi = speed
	if Input.is_key_pressed(KEY_A): left += 1
	if Input.is_key_pressed(KEY_D): left += -1
	if Input.is_key_pressed(KEY_W): forward += 1
	if Input.is_key_pressed(KEY_S): forward -= 1
	if Input.is_key_pressed(KEY_MINUS): up += 1
	if Input.is_key_pressed(KEY_EQUAL): up -= 1
	if Input.is_key_pressed(KEY_SHIFT): multi = run_speed
	if left != 0:
		position.x += delta * left * multi
	if forward != 0:
		position.z += delta * forward * multi
	if up != 0:
		position.y += delta * up * multi
	if left != 0 or forward != 0 or up != 0:
		$"../Pos".text = "Pos: " + str(int(position.x)) + "," + str(int(position.y)) + "," + str(int(position.z))
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
	pass
