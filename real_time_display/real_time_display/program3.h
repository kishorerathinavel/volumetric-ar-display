#pragma once
#include "common_var_func.h"
#define PROG3_NUM_OUTPUT_TEXTURES 2
class program3_class {
public:
	// Shader Names
	char *fname_vertex_shader, *fname_fragment_shader;
	
	GLuint fbo_rgb, tex_rgb[PROG3_NUM_OUTPUT_TEXTURES];

	
	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint rgb_img, depth_map;
	GLuint zNear, zFar;


	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	program3_class();
	~program3_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};
