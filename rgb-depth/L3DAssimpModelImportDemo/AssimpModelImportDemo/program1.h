#pragma once
#include "common_var_func.h"
#include "filepaths.h"
#include "model.h"

// This is for a shader uniform block
struct MyMaterial {
	float diffuse[4];
	float ambient[4];
	float specular[4];
	float emissive[4];
	float shininess;
	int texCount;
};

class program1_class {
public:
	GLuint rbo_depth_image, fbo_rgbd, tex_rgb, tex_depth;

	// Vertex Attribute Locations
	GLuint program1_vertexLoc, program1_normalLoc, program1_texCoordLoc;

	// Uniform Bindings Points
	GLuint matricesUniLoc, materialUniLoc;

	// The sampler uniform for textured models
	// we are assuming a single texture so this will
	//always be texture unit 0
	GLuint texUnit;

	// Uniform Buffer for Matrices
	// this buffer will contain 3 matrices: projection, view and model
	// each matrix is a float array with 16 components
	GLuint matricesUniBuffer;
	// Program and Shader Identifiers
	GLuint program, vertexShader, fragmentShader;

	// Shader Names
	char *fname_vertex_shader;
	char *fname_fragment_shader_rgb;

	program1_class();
	~program1_class();
	void delayed_init();
	void genVAOs(Model&);
	GLuint setup_shaders();
};

