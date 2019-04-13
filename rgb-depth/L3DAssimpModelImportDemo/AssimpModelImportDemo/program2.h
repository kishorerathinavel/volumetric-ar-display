# pragma once
#include "common_var_func.h"

class program2_class {
public:
	GLuint fbo_synthetic1_rgb, tex_synthetic1_rgb;

	// Vertex Attribute Locations
	GLuint synthetic1_vertexLoc, synthetic1_textureLoc;

	// Sampler Uniform
	GLuint synthetic1_rgb_img, synthetic1_depth_map;

	// Float Uniforms

	// Program and Shader Identifiers
	GLuint program2, synthetic1_vertexShader, synthetic1_fragmentShader;

	// Shader Names
	char *fname_synthetic1_vertex_shader;
	char *fname_synthetic1_fragment_shader;

	program2_class();
	~program2_class();
	void delayed_init();
	void genVAOs();
	GLuint setup_shaders();
};



