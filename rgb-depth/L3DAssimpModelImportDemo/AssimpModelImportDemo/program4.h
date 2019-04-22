#pragma once
#include "common_var_func.h"

class program4_class {
public:
	// Shader Names
	char *fname_vertex_shader, *fname_fragment_shader;

	GLuint fbo_rgb, tex_rgb[8];
	
	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint rgb_img[8];

	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	program4_class();
	~program4_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};
