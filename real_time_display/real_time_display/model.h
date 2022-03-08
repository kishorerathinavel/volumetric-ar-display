#pragma once
#include "common_var_func.h"

#define NUM_MODELS 2

// Information to render each assimp node
struct MyMesh {
	GLuint vao;
	GLuint texIndex;
	GLuint uniformBlockIndex;
	int numFaces;
};

void set_float4(float f[4], float a, float b, float c, float d);
void color4_to_float4(const aiColor4D *c, float f[4]);

#ifndef MODEL_CLASS
#define MODEL_CLASS
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
	bool Import3DFromFile();
	int LoadGLTextures();
};
#endif

extern Model model[NUM_MODELS];



