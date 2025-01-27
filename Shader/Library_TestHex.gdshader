shader_type spatial;

uniform int tileType = 0;

float get_offSet_x(float x){
	return (0.11 * sin(x * 7.3 + 4.0)) + (0.23 * sin(x * 2.6 + 0.7)) + (0.07 * sin(x * 6.1 + 6.0)) + (0.09 * sin(x * 9.2 + 3.14));
}
float get_offSet_y(float y){
	return (0.21 * sin(y * 6.1 + 7.11)) + (0.13 * sin(y * 1.6 + 12.0)) + (0.11 * sin(y * 4.1 + 5.0)) + (0.05 * sin(y * 2.2 + 2.12));
}


void vertex() {
	// Called for every vertex the material is visible on.
	//VERTEX = vec3(
		//VERTEX.x - (NODE_POSITION_WORLD.x * 0.133) + (NODE_POSITION_WORLD.z * 0.434), 
		//VERTEX.y, 
		//VERTEX.z - (NODE_POSITION_WORLD.z * 0.251));
	//VERTEX.y = sin(VERTEX.x - (NODE_POSITION_WORLD.x * 0.133) + (NODE_POSITION_WORLD.z * 0.434));
	vec3 v = NODE_POSITION_WORLD + VERTEX;
	float z = VERTEX.z;
	float x = VERTEX.x;
	 //VERTEX.x += get_offSet_x(v.x + (256.0*v.z) ) - NODE_POSITION_WORLD.x;
	 ////VERTEX.y += VERTEX.y * VERTEX.y;
	 //VERTEX.z += get_offSet_y(v.z + (256.0*v.x) ) - NODE_POSITION_WORLD.z;
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
