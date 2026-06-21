shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec3 top = vec3(0.1, 0.3, 0.8);
    vec3 bottom = vec3(0.4, 0.3, 1.0);

    COLOR.rgb = mix(top, bottom, UV.y);
    COLOR.a = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
