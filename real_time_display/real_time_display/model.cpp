#include "model.h"

#define aisgl_min(x,y) (x<y?x:y)
#define aisgl_max(x,y) (y>x?y:x)

void get_bounding_box_for_node(const aiNode* nd, aiVector3D* min, aiVector3D* max, const aiScene* scene) {
	aiMatrix4x4 prev;
	unsigned int n = 0, t;

	for (; n < nd->mNumMeshes; ++n) {
		const aiMesh* mesh = scene->mMeshes[nd->mMeshes[n]];
		for (t = 0; t < mesh->mNumVertices; ++t) {

			aiVector3D tmp = mesh->mVertices[t];

			min->x = aisgl_min(min->x, tmp.x);
			min->y = aisgl_min(min->y, tmp.y);
			min->z = aisgl_min(min->z, tmp.z);

			max->x = aisgl_max(max->x, tmp.x);
			max->y = aisgl_max(max->y, tmp.y);
			max->z = aisgl_max(max->z, tmp.z);
		}
	}

	for (n = 0; n < nd->mNumChildren; ++n) {
		get_bounding_box_for_node(nd->mChildren[n], min, max, scene);
	}
}


void get_bounding_box(aiVector3D* min, aiVector3D* max, const aiScene* scene) {
	min->x = min->y = min->z = 1e10f;
	max->x = max->y = max->z = -1e10f;
	get_bounding_box_for_node(scene->mRootNode, min, max, scene);
}

//// Can't send color down as a pointer to aiColor4D because AI colors are ABGR.
//void Color4f(const aiColor4D *color)
//{
//	glColor4f(color->r, color->g, color->b, color->a);
//}

void set_float4(float f[4], float a, float b, float c, float d) {
	f[0] = a;
	f[1] = b;
	f[2] = c;
	f[3] = d;
}

void color4_to_float4(const aiColor4D *c, float f[4]) {
	f[0] = c->r;
	f[1] = c->g;
	f[2] = c->b;
	f[3] = c->a;
}

Model::Model() {
	this->scene = NULL;
	this->scaleFactor = 0.05;
}

Model::~Model() {
	this->textureIdMap.clear();
	// clear myMeshes stuff
	for (unsigned int i = 0; i < this->myMesh.size(); ++i) {
		glDeleteVertexArrays(1, &(this->myMesh[i].vao));
		glDeleteTextures(1, &(this->myMesh[i].texIndex));
		glDeleteBuffers(1, &(this->myMesh[i].uniformBlockIndex));
	}
}

bool Model::Import3DFromFile() {

	std::string pFile = this->basepath + this->modelname;
	//check if file exists
	std::ifstream fin(pFile.c_str());
	if (!fin.fail()) {
		fin.close();
	}
	else {
		printf("Couldn't open file: %s\n", pFile.c_str());
		printf("%s\n", this->importer.GetErrorString());
		return false;
	}

	printf("Reading file... \n");
	this->scene = this->importer.ReadFile(pFile, aiProcessPreset_TargetRealtime_Quality);
	// If the import failed, report it
	if (!this->scene)
	{
		printf("%s\n", this->importer.GetErrorString());
		return false;
	}

	printf("Done reading file... \n");


	// Now we can access the file's contents.
	printf("Import of scene %s succeeded. \n", pFile.c_str());

	//float tempScaleFactor;
	//aiVector3D scene_min, scene_max, scene_center;
	//get_bounding_box(&scene_min, &scene_max, scene);
	//float tmp;
	//tmp = scene_max.x-scene_min.x;
	//tmp = scene_max.y - scene_min.y > tmp?scene_max.y - scene_min.y:tmp;
	//tmp = scene_max.z - scene_min.z > tmp?scene_max.z - scene_min.z:tmp;
	//tempScaleFactor = 1.0 / tmp;

	// We're done. Everything will be cleaned up by the importer destructor
	return true;
}


int Model::LoadGLTextures() {
	ILboolean success;

	/* scan scene's materials for textures */
	for (unsigned int m = 0; m < this->scene->mNumMaterials; ++m)
	{
		int texIndex = 0;
		aiString path;	// filename

		aiReturn texFound = this->scene->mMaterials[m]->GetTexture(aiTextureType_DIFFUSE, texIndex, &path);
		while (texFound == AI_SUCCESS) {
			//fill map with textures, OpenGL image ids set to 0
			this->textureIdMap[path.data] = 0;
			// more textures?
			texIndex++;
			texFound = this->scene->mMaterials[m]->GetTexture(aiTextureType_DIFFUSE, texIndex, &path);
		}
	}

	int numTextures = this->textureIdMap.size();

	/* create and fill array with DevIL texture ids */
	ILuint* imageIds = new ILuint[numTextures];
	ilGenImages(numTextures, imageIds);

	/* create and fill array with GL texture ids */
	GLuint* textureIds = new GLuint[numTextures];
	glGenTextures(numTextures, textureIds); /* Texture name generation */

	/* get iterator */
	std::map<std::string, GLuint>::iterator itr = this->textureIdMap.begin();
	int i = 0;
	for (; itr != this->textureIdMap.end(); ++i, ++itr)
	{
		//save IL image ID
		std::string filename = (*itr).first;  // get filename
		(*itr).second = textureIds[i];	  // save texture id for filename in map

		ilBindImage(imageIds[i]); /* Binding of DevIL image name */
		ilEnable(IL_ORIGIN_SET);
		ilOriginFunc(IL_ORIGIN_LOWER_LEFT);
		std::string fileloc = this->basepath + filename;	/* Loading of image */
		success = ilLoadImage(fileloc.c_str());
		if (success) {
			/* Convert image to RGBA */
			ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE);

			/* Create and load textures to OpenGL */
			glBindTexture(GL_TEXTURE_2D, textureIds[i]);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, ilGetInteger(IL_IMAGE_WIDTH),
				ilGetInteger(IL_IMAGE_HEIGHT), 0, GL_RGBA, GL_UNSIGNED_BYTE,
				ilGetData());
		}
		else
			printf("Couldn't load Image: %s\n", filename.c_str());
	}
	/* Because we have already copied image data into texture data
	we can release memory used by image. */
	ilDeleteImages(numTextures, imageIds);

	//Cleanup
	delete[] imageIds;
	delete[] textureIds;

	//return success;
	return true;
}


