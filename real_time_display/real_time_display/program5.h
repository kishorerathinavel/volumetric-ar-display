#pragma once
#include "common_var_func.h"

class program5_class {
public:
	// Shader Names
	char *fname_vertex_shader, *fname_fragment_shader;

	GLuint fbo_binary, tex_binary[8];
	
	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint gray_img[8];

	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	program5_class();
	~program5_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};
