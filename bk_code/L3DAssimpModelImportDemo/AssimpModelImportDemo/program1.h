#pragma once
#include "common_var_func.h"
#include "filepaths.h"

#define MatricesUniBufferSize sizeof(float) * 16 * 3
#define ProjMatrixOffset 0
#define ViewMatrixOffset sizeof(float) * 16
#define ModelMatrixOffset sizeof(float) * 16 * 2
#define MatrixSize sizeof(float) * 16

// This is for a shader uniform block
struct MyMaterial {
	float diffuse[4];
	float ambient[4];
	float specular[4];
	float emissive[4];
	float shininess;
	int texCount;
};

// Information to render each assimp node
struct MyMesh {
	GLuint vao;
	GLuint texIndex;
	GLuint uniformBlockIndex;
	int numFaces;
};


#define NUM_MODELS 3
class Model {
public:
	std::vector<struct MyMesh> myMesh;
	Assimp::Importer importer;
	const aiScene* scene;
	std::map<std::string, GLuint> textureIdMap;
	std::string basepath;
	std::string modelname;
	float scaleFactor;
	float translation[3];
	float rotation[3];

	Model();
	~Model();
};

class program1_class {
public:
	Model model[NUM_MODELS];

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
	void delayed_init();
	void genVAOs(Model&);
	GLuint setup_shaders();
};
