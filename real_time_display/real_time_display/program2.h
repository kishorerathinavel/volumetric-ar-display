# pragma once
#include "common_var_func.h"

class program2_class {
public:
	GLuint fbo_rgb, tex_rgb;

	// Vertex Attribute Locations
	GLuint vertexLoc, textureLoc;

	// Sampler Uniform
	GLuint rgb_img, depth_map;

	// Float Uniforms

	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	// Shader Names
	char *fname_vertex_shader;
	char *fname_fragment_shader;

	program2_class();
	~program2_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};



