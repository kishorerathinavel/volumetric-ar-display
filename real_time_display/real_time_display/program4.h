#pragma once
#include "common_var_func.h"
#include "program3.h"

class program4_class {
public:
	// Shader Names
	char *fname_vertex_shader, *fname_fragment_shader;

	GLuint fbo_gray, tex_gray[8];
	
	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint rgb_img[PROG3_NUM_OUTPUT_TEXTURES];
	GLuint brightness[3];


	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	program4_class();
	~program4_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};
