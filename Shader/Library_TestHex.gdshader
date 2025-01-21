shader_type spatial;

uniform int tileType = 0;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX = vec3(
		VERTEX.x - (NODE_POSITION_WORLD.x * 0.133) + (NODE_POSITION_WORLD.z * 0.434), 
		VERTEX.y, 
		VERTEX.z - (NODE_POSITION_WORLD.z * 0.251));
	//VERTEX.y = sin(VERTEX.x - (NODE_POSITION_WORLD.x * 0.133) + (NODE_POSITION_WORLD.z * 0.434));
}

void fragment() {
	// Called for every pixel the material is visible on.
	switch(tileType){
		case 0:
			//Dirt
			ALBEDO = vec3(0.587,0.418,0.266);
			break;
		case 1:
			//Grass
			ALBEDO = vec3(0.307,0.467,0.126);
			break;
		case 2:
			//Stone
			ALBEDO = vec3(0.482,0.482,0.482);
			break;
		case 3:
			//Water
			ALBEDO = vec3(0.16,0.466,0.662);
			break;
	};
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
