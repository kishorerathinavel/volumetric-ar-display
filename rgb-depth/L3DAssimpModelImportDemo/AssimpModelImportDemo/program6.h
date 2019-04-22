#pragma once
#include "common_var_func.h"

class program6_class {
public:
	// Shader Names
	char *fname_vertex_shader, *fname_fragment_shader;

	GLuint fbo_encoded, tex_encoded;
	
	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint binary_img[8];

	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	program6_class();
	~program6_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};
