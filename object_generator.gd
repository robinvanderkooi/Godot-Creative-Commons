extends Node3D

@export var width = 100
@export var height = 100

var objects = [] #2D array

var grid_read = []
var grid_write = []
var grid_clearing = []
var grid_clearings = []

enum obj_type{
	notset = 0,
	dirt = 1,
	grass = 2
}
enum clearing_type{
	dead_zone = 0
}
enum special_buildings{
	dead_tree = 0
}

var time = 0.0

var trigger_generation = true
var instance_terrains = false
var check_thread = true

var thread : Thread

func _ready() -> void:
	#self.set_process(false) # For now. While i'm learning. And I can see the grid.
	#GridMap is quite performant. Might do that for scenery. Combined with orientation
	
	#var grass_count = 0
	#var dirt_count = 0
	#for x in range(-5,6,1):
		#for y in range(-5,6,1):
			#for z in range(-5,6,1):
				#var vecci = Vector3i(x,y,z)
				#var i = %Gridy.get_cell_item(vecci)
				#var o = %Gridy.get_cell_item_orientation(vecci)
				#if i != -1 :
					#print( "x:" + str(x) + " y:" + str(y) + " z:" + str(z) + " i:" + str(i) + " o:" + str(o) )
				#if i == 0:
					#dirt_count += 1
				#if i == 1:
					#grass_count += 1
	#print("Dirt: " + str(dirt_count))
	#print("Grass: " + str(grass_count))
	
	
	pass

func _process(delta: float) -> void:
	if trigger_generation:
		trigger_generation = false
		print("do_the_thing_Start: "+str(Time.get_time_dict_from_system()))
		do_the_thing()
		print("do_the_thing_Stop: "+str(Time.get_time_dict_from_system()))
		#thread = Thread.new() # The thread thing seemed to hurt the debugger. Performed worse with it running.
		#thread.start(do_the_thing.bind())
	elif instance_terrains:
		instance_terrains = false
		#instanciate_terrains() #THIS IS PRETTY BAD! 40,000 Meshes works but does not debug well. 
		#                       Also took much longer to make them and dropped the frame rate. 10 seconds to load. 90 fps.
		print("instanciate_terrains2_Start: "+str(Time.get_time_dict_from_system()))
		instanciate_terrains2() # Gridmap. < 1 sec to load. 118 fps
		print("instanciate_terrains2_Stop: "+str(Time.get_time_dict_from_system()))
		#thread.wait_to_finish()
		#thread = null
	#print(str(thread.is_alive())+","+str(thread.is_started()))
	#if check_thread && ! thread.is_alive():
		#check_thread = false
		#thread.wait_to_finish()

	time += delta
	pass

func do_the_thing():
	print("doing the thing")
	init_grid()
	_generate_island_noisemap()
	generate_terrain()
	instance_terrains = true
	print("did the thing")

func init_grid():
	for x in range(width):
		grid_read.append([])
		grid_write.append([])
		grid_clearing.append([])
		for y in range(height):
			grid_read[x].append(0)
			grid_write[x].append(0)
			grid_clearing[x].append(0)
	
func clear_grid():
	for x in range(width):
		for y in range(height):
			grid_read[x][y] = 0
			grid_write[x][y] = 0

func _generate_island_noisemap():
	#var texture1 := NoiseTexture2D.new()
	#var noisy1 := FastNoiseLite.new()
	#noisy1.fractal_octaves = 11
	#noisy1.noise_type = FastNoiseLite.TYPE_SIMPLEX
	#texture1.width = 2024
	#texture1.height = 2024
	#texture1.noise = noisy1
	#await texture1.changed
	#var image1 = texture1.get_image()
	#var data = image1.get_data()
	#%IslandNoiseMap.texture = texture1
	var tex1:NoiseTexture2D = %IslandMap1.texture
	var tex2:GradientTexture2D = %IslandMap2.texture
	var tex3:ImageTexture = ImageTexture.new()
	var image1:Image = tex1.get_image()
	var image2:Image = tex2.get_image()
	#var hmmm2 = image1.get_data()
	#var tex3 = tex1.get_size()
	var start_time = Time.get_ticks_msec()
	for x:int in range(image1.get_width()):
		for y:int in range(image1.get_height()):
			var samp1 = image1.get_pixel(x,y)
			var samp2 = image2.get_pixel(x,y)
			var b = samp1.r * samp2.r
			#if b < 0.1: b = 0.0
			image1.set_pixel(x,y,Color(b,b,b,1))
			pass
	tex3.set_image(image1)
	%IslandMap3.texture = tex3
	var final_time_millis = (Time.get_ticks_msec() - start_time)
	pass

func generate_terrain():
	var randy = RandomNumberGenerator.new()
	for x in range(width):
		for y in range(height):
			if randy.randf() > 0.5:
				set_this_this(x,y,obj_type.dirt)
			else:
				set_this_this(x,y,obj_type.grass)
	make_clearing(clearing_type.dead_zone)
	make_clearing(clearing_type.dead_zone)
	make_clearing(clearing_type.dead_zone)
	var smooth_iterations = 4
	for i in smooth_iterations:
		copy_written_to_reading()
		for x in range(width):
			for y in range(height):
				var grass_count = 0
				for n in [-1,0,+1]:
					for m in [-1,0,+1]:
						if n != 0 or m != 0:
							if is_this_this((x+n+width)%width,(y+m+height)%height, obj_type.grass): 
								grass_count += 1
				
				if is_this_this(x,y, obj_type.dirt) and grass_count >= 6: 
					set_this_this(x,y,obj_type.grass)
				
				if is_this_this(x,y, obj_type.grass) and grass_count < 3:
					set_this_this(x,y,obj_type.dirt)
				
	copy_written_to_reading()

func is_this_this(x : int, y : int, t : obj_type) -> bool:
	return grid_read[x][y] & t == t
func set_this_this(x : int, y : int, t : obj_type):
	grid_write[x][y] = t
func copy_written_to_reading():
	for x in range(width):
		for y in range(height):
			grid_read[x][y] = grid_write[x][y]


func get_randVertOrient() -> int:
	match randi() % 4:
		0:
			return 0
		1:
			return 10
		2:
			return 16
		3:
			return 24
	return 0

func make_clearing(c : clearing_type):
	#Determine the clearing radius
	var radius = 0
	if c == clearing_type.dead_zone:
		radius = 10
	if radius != 0:
		var square_radius = pow(radius, 2)
		
		#Pick a random spot
		var x = -1
		var y = -1
		var restart = false
		var safety = 10000
		while safety > 0:
			safety -= 1
			x = randi_range(0 + radius, width - (radius + 1))
			y = randi_range(0 + radius, height - (radius + 1))
			for n in range(x - radius, x + radius):
				if restart: break
				for m in range(y - radius, y + radius):
					if restart: break
					if Vector2(x,y).distance_squared_to(Vector2(n,m)) <= square_radius:
						if grid_clearing[n][m] == 1:
							restart = true
			
			if not restart: 
				grid_clearings.append(Vector2(x,y))
				break # get out of the safety loop
		if not restart:
			#We got here with a location for the clearing.
			print("Got a clearing at " + str(x) + ", " + str(y))
			var square_distance = 999.9
			for n in range(x - radius, x + radius):
				for m in range(y - radius, y + radius):
					square_distance = Vector2(x,y).distance_squared_to(Vector2(n,m))
					if square_distance <= square_radius:
						grid_clearing[n][m] = 1
						var half_r = float(radius) / 2.0
						var d = Vector2(x,y).distance_to(Vector2(n,m))
						if d <= half_r:
							set_this_this(n,m,obj_type.dirt)
						elif (d - half_r) / half_r < randf():
							set_this_this(n,m,obj_type.dirt)
			pass
		else:
			print("Clearing failed")
	
	pass

func instanciate_terrains2():
	var tex : Texture2D = %IslandMap3.texture
	var im :Image= tex.get_image()
	for x in range(width):
		for y in range(height):
			var c : Color = im.get_pixel(x,y)
			var h = int( c.r * 24.0 )
			#if grid_clearing[x][y] == 1:
				#%Gridy.set_cell_item(Vector3i(x,0,y),0,0)
			if _check_clearings(Vector2(x,y)):
				var off:Vector2 = _get_offset(Vector2(x,y))
				var new_x = x * 10 + int(off.x * 10.0)
				var new_y = y * 10 + int(off.y * 10.0)
				%TreeMap.set_cell_item(Vector3i(new_x,1,new_y),2,get_randVertOrient())
			if is_this_this(x,y,obj_type.grass):
				%Gridy.set_cell_item(Vector3i(x,h,y),1,0)
				if randf() <= 0.66:
					var off:Vector2 = _get_offset(Vector2(x,y))
					var new_x = x * 10 + int(off.x * 10.0)
					var new_y = y * 10 + int(off.y * 10.0)
					if randf() < 0.5:
						%TreeMap.set_cell_item(Vector3i(new_x,1,new_y),0,get_randVertOrient())
					else:
						%TreeMap.set_cell_item(Vector3i(new_x,1,new_y),1,get_randVertOrient())
			elif is_this_this(x,y, obj_type.dirt):
				%Gridy.set_cell_item(Vector3i(x,h,y),0,0)
				if randf() <= 0.3 and grid_clearing[x][y] == 0:
					var off:Vector2 = _get_offset(Vector2(x,y))
					var new_x = x * 10 + int(off.x * 10.0)
					var new_y = y * 10 + int(off.y * 10.0)
					if randf() < 0.5:
						%TreeMap.set_cell_item(Vector3i(new_x,1,new_y),0,get_randVertOrient())
					else:
						%TreeMap.set_cell_item(Vector3i(new_x,1,new_y),1,get_randVertOrient())
	pass

func _check_clearings(v : Vector2) -> bool:
	for clearing in grid_clearings:
		if clearing.x == v.x and clearing.y == v.y:
			return true
	return false

func _get_offset(v:Vector2i) -> Vector2:
	var x = (0.11 * sin(v.x * 7.3 + 4)) + (0.23 * sin(v.x * 2.6 + 0.7)) + (0.07 * sin(v.x * 6.1 + 6)) + (0.09 * sin(v.x * 9.2 + 3.14))
	var y = (0.21 * sin(v.y * 6.1 + 7.11)) + (0.13 * sin(v.y * 1.6 + 12)) + (0.11 * sin(v.y * 4.1 + 5)) + (0.05 * sin(v.y * 2.2 + 2.12))
	return Vector2(x,y)
