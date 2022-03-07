#pragma once
#include "common_var_func.h"

class program7_class {
public:
	// Shader Names
	char *fname_vertex_shader, *fname_fragment_shader;

	GLuint fbo, tex;
	
	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint rgb_img;

	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	program7_class();
	~program7_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};
