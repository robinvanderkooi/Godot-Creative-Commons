extends Node3D

@export var width = 100
@export var height = 100

var objects = [] #2D array

var grid_read = []
var grid_write = []

enum obj_type{
	notset = 0,
	dirt = 1,
	grass = 2,
	clearing = 4,
	rock = 8,
	scrub = 16,
	tree = 32,
	flower = 64
}

var time = 0.0

var map_generated

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
		do_the_thing()
		#thread = Thread.new() # The thread thing seemed to hurt the debugger. Performed worse with it running.
		#thread.start(do_the_thing.bind())
	elif instance_terrains:
		instance_terrains = false
		#instanciate_terrains() #THIS IS PRETTY BAD! 40,000 Meshes works but does not debug well. 
		#                       Also took much longer to make them and dropped the frame rate. 10 seconds to load. 90 fps.
		instanciate_terrains2() # Gridmap. < 1 sec to load. 118 fps
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
	generate_terrain()
	instance_terrains = true
	print("did the thing")

func init_grid():
	for x in range(width):
		grid_read.append([])
		grid_write.append([])
		for y in range(height):
			grid_read[x].append(0)
			grid_write[x].append(0)
	
func clear_grid():
	for x in range(width):
		for y in range(height):
			grid_read[x][y] = 0
			grid_write[x][y] = 0

func generate_terrain():
	var randy = RandomNumberGenerator.new()
	for x in range(width):
		for y in range(height):
			if randy.randf() > 0.5:
				set_this_this(x,y,obj_type.dirt)
			else:
				set_this_this(x,y,obj_type.grass)
	var smooth_iterations = 2
	for i in smooth_iterations:
		copy_written_to_reading()
		for x in range(width):
			for y in range(height):
				var grass_count = 0
				for n in [-1,0,+1]:
					for m in [-1,0,+1]:
						if is_this_this((x+n)%(width-1),(y+m)%(height-1), obj_type.grass): grass_count += 1
				if grass_count > 6: 
					set_this_this(x,y,obj_type.grass)
				elif grass_count < 4:
					set_this_this(x,y,obj_type.dirt)
	copy_written_to_reading()

func is_this_this(x : int, y : int, t : obj_type) -> bool:
	return grid_read[x][y] & t == t
func set_this_this(x : int, y : int, t : obj_type):
	grid_write[x][y] = t
func flag_this_this(x : int, y : int, t : obj_type):
	grid_write[x][y] = grid_write[x][y] | t
func swap_read_write():
	var temp = grid_read
	grid_read = grid_write
	grid_write = temp
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

func instanciate_terrains2():
	for x in range(width):
		for y in range(height):
			if is_this_this(x,y,obj_type.grass):
				%Gridy.set_cell_item(Vector3i(x,0,y),1,0)
				if randf() <= 0.66:
					if randf() < 0.5:
						%TreeMap.set_cell_item(Vector3i(x,1,y),0,get_randVertOrient())
					else:
						%TreeMap.set_cell_item(Vector3i(x,1,y),1,get_randVertOrient())
			elif is_this_this(x,y, obj_type.dirt):
				%Gridy.set_cell_item(Vector3i(x,0,y),0,0)
				if randf() <= 0.3:
					if randf() < 0.5:
						%TreeMap.set_cell_item(Vector3i(x,1,y),0,get_randVertOrient())
					else:
						%TreeMap.set_cell_item(Vector3i(x,1,y),1,get_randVertOrient())
	pass
