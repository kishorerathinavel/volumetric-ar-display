//
// Lighthouse3D.com OpenGL 3.3 + GLSL 3.3 Sample
//
// Loading and displaying a Textured Model
//
// Uses:
//  Assimp lybrary for model loading
//		http://assimp.sourceforge.net/
//  Devil for image loading
//		http://openil.sourceforge.net/
//	Uniform Blocks
//  Vertex Array Objects
//
// Some parts of the code are strongly based on the Assimp 
// SimpleTextureOpenGL sample that comes with the Assimp 
// distribution, namely the code that relates to loading the images
// and the model.
//
// The code was updated and modified to be compatible with 
// OpenGL 3.3 CORE version
//
// This demo was built for learning purposes only. 
// Some code could be severely optimised, but I tried to 
// keep as simple and clear as possible.
//
// The code comes with no warranties, use it at your own risk.
// You may use it, or parts of it, wherever you want. 
//
// If you do use it I would love to hear about it. Just post a comment
// at Lighthouse3D.com

// Have Fun :-)

#ifdef _WIN32
#pragma comment(lib,"assimp.lib")
#pragma comment(lib,"devil.lib")
#pragma comment(lib,"glew32.lib")
#endif

#include "common_var_func.h"
#include "model.h"
#include "program1.h"
#include "program2.h"
#include "program3.h"
#include "program4.h"
#include "program5.h"
#include "program6.h"
#include "program7.h"
#include "filepaths.h"
#include "mat.h"
#include "matrix.h"


bool display_on_device = !true;
int display_1[] ={ 2560, 1600 };
int display_2[] ={ 2560, 1600 };
int window_position[] ={0, 0 };
int window_size[] ={ 1920, 1080 };

// Model Matrix (part of the OpenGL Model View Matrix)
float modelMatrix[16];

// For push and pop matrix
std::vector<float *> matrixStack;

//float zNear = 0.01, zFar = 21.1;
float zNear = 0.20, zFar = 4.00;

// Camera Position
float camX = 0, camY = 0, camZ = 1.2;

// Mouse Tracking Variables
int startX, startY, tracking = 0;

// Camera Spherical Coordinates
float alpha = 0.0f, beta = 0.0f;
float r = 1.2f;

bool saveFramebufferOnce = false;
bool saveFramebufferUntilStop = false;

GLuint tex_background;

#define M_PI       3.14159265358979323846f

// Uniform Buffer for Matrices
// this buffer will contain 3 matrices: projection, view and model
// each matrix is a float array with 16 components
GLuint matricesUniBuffer;
#define MatricesUniBufferSize sizeof(float) * 16 * 3
#define ProjMatrixOffset 0
#define ViewMatrixOffset sizeof(float) * 16
#define ModelMatrixOffset sizeof(float) * 16 * 2
#define MatrixSize sizeof(float) * 16

Model model[NUM_MODELS];

program1_class prog1;
program2_class prog2;
program3_class prog3;
program4_class prog4;
program5_class prog5;
program6_class prog6;
program7_class prog7;


// For Program 3 ||||||||||||||||||||||||||||||||||||||
GLuint fbo_bitplanes_rgb, tex_bitplanes_rgb;

// Vertex Attribute Locations
GLuint bitplanes_vertexLoc, bitplanes_textureLoc;

// Sampler Uniform
GLuint bitplanes_rgb_img, bitplanes_depth_map;

// Float Uniforms

// Program and Shader Identifiers
GLuint bitplanes_program, bitplanes_vertexShader, bitplanes_fragmentShader;

// Shader Names
char *fname_bitplanes_vertex_shader = "synthetic1.vert";
char *fname_bitplanes_fragment_shader = "bitplanes.frag";

// END For Program 3 |||||||||||||||||||||||||||||||||||||

static inline float DegToRad(float degrees) {
	return (float)(degrees * (M_PI / 180.0f));
};

// Frame counting and FPS computation
long time_fps, timebase = 0, frame = 0;
char s[32];

//-----------------------------------------------------------------
// Print for OpenGL errors
//
// Returns 1 if an OpenGL error occurred, 0 otherwise.
//

#define printOpenGLError() printOglError(__FILE__, __LINE__)

int printOglError(char *file, int line) {

	GLenum glErr;
	int    retCode = 0;

	glErr = glGetError();
	if (glErr != GL_NO_ERROR)
	{
		printf("glError in file %s @ line %d: %s\n",
			file, line, gluErrorString(glErr));
		retCode = 1;
	}
	return retCode;
}


// ----------------------------------------------------
// VECTOR STUFF
//


// res = a cross b;
void crossProduct(float *a, float *b, float *res) {
	res[0] = a[1] * b[2] - b[1] * a[2];
	res[1] = a[2] * b[0] - b[2] * a[0];
	res[2] = a[0] * b[1] - b[0] * a[1];
}


// Normalize a vec3
void normalize(float *a) {
	float mag = sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);

	a[0] /= mag;
	a[1] /= mag;
	a[2] /= mag;
}


// ----------------------------------------------------
// MATRIX STUFF
//

// Push and Pop for modelMatrix

void pushMatrix() {
	float *aux = (float *)malloc(sizeof(float) * 16);
	memcpy(aux, modelMatrix, sizeof(float) * 16);
	matrixStack.push_back(aux);
}

void popMatrix() {
	float *m = matrixStack[matrixStack.size() - 1];
	memcpy(modelMatrix, m, sizeof(float) * 16);
	matrixStack.pop_back();
	free(m);
}

// sets the square matrix mat to the identity matrix,
// size refers to the number of rows (or columns)
void setIdentityMatrix(float *mat, int size) {
	// fill matrix with 0s
	for (int i = 0; i < size * size; ++i)
		mat[i] = 0.0f;

	// fill diagonal with 1s
	for (int i = 0; i < size; ++i)
		mat[i + i * size] = 1.0f;
}


//
// a = a * b;
//
void multMatrix(float *a, float *b) {
	float res[16];

	for (int i = 0; i < 4; ++i) {
		for (int j = 0; j < 4; ++j) {
			res[j * 4 + i] = 0.0f;
			for (int k = 0; k < 4; ++k) {
				res[j * 4 + i] += a[k * 4 + i] * b[j * 4 + k];
			}
		}
	}
	memcpy(a, res, 16 * sizeof(float));
}


// Defines a transformation matrix mat with a translation
void setTranslationMatrix(float *mat, float x, float y, float z) {
	setIdentityMatrix(mat, 4);
	mat[12] = x;
	mat[13] = y;
	mat[14] = z;
}

// Defines a transformation matrix mat with a scale
void setScaleMatrix(float *mat, float sx, float sy, float sz) {
	setIdentityMatrix(mat, 4);
	mat[0] = sx;
	mat[5] = sy;
	mat[10] = sz;
}

// Defines a transformation matrix mat with a rotation 
// angle alpha and a rotation axis (x,y,z)
void setRotationMatrix(float *mat, float angle, float x, float y, float z) {
	float radAngle = DegToRad(angle);
	float co = cos(radAngle);
	float si = sin(radAngle);
	float x2 = x*x;
	float y2 = y*y;
	float z2 = z*z;

	mat[0] = x2 + (y2 + z2) * co;
	mat[4] = x * y * (1 - co) - z * si;
	mat[8] = x * z * (1 - co) + y * si;
	mat[12] = 0.0f;

	mat[1] = x * y * (1 - co) + z * si;
	mat[5] = y2 + (x2 + z2) * co;
	mat[9] = y * z * (1 - co) - x * si;
	mat[13] = 0.0f;

	mat[2] = x * z * (1 - co) - y * si;
	mat[6] = y * z * (1 - co) + x * si;
	mat[10] = z2 + (x2 + y2) * co;
	mat[14] = 0.0f;

	mat[3] = 0.0f;
	mat[7] = 0.0f;
	mat[11] = 0.0f;
	mat[15] = 1.0f;
}

// ----------------------------------------------------
// Model Matrix 
//
// Copies the modelMatrix to the uniform buffer


void setModelMatrix() {
	glBindBuffer(GL_UNIFORM_BUFFER, matricesUniBuffer);
	glBufferSubData(GL_UNIFORM_BUFFER, ModelMatrixOffset, MatrixSize, modelMatrix);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
}

// The equivalent to glTranslate applied to the model matrix
void translate(float x, float y, float z) {
	float aux[16];

	setTranslationMatrix(aux, x, y, z);
	multMatrix(modelMatrix, aux);
	setModelMatrix();
}

// The equivalent to glRotate applied to the model matrix
void rotate(float angle, float x, float y, float z) {
	float aux[16];

	setRotationMatrix(aux, angle, x, y, z);
	multMatrix(modelMatrix, aux);
	setModelMatrix();
}

// The equivalent to glScale applied to the model matrix
void scale(float x, float y, float z) {
	float aux[16];

	setScaleMatrix(aux, x, y, z);
	multMatrix(modelMatrix, aux);
	setModelMatrix();
}

// ----------------------------------------------------
// Projection Matrix 
//
// Computes the projection Matrix and stores it in the uniform buffer

void buildProjectionMatrix(float fov, float ratio, float nearp, float farp) {
	float projMatrix[16];

	float f = 1.0f / tan(fov * (M_PI / 360.0f));

	setIdentityMatrix(projMatrix, 4);

	projMatrix[0] = f / ratio;
	projMatrix[1 * 4 + 1] = f;
	projMatrix[2 * 4 + 2] = (farp + nearp) / (nearp - farp);
	projMatrix[3 * 4 + 2] = (2.0f * farp * nearp) / (nearp - farp);
	projMatrix[2 * 4 + 3] = -1.0f;
	projMatrix[3 * 4 + 3] = 0.0f;

	glBindBuffer(GL_UNIFORM_BUFFER, matricesUniBuffer);
	glBufferSubData(GL_UNIFORM_BUFFER, ProjMatrixOffset, MatrixSize, projMatrix);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
}


// ----------------------------------------------------
// View Matrix
//
// Computes the viewMatrix and stores it in the uniform buffer
//
// note: it assumes the camera is not tilted, 
// i.e. a vertical up vector along the Y axis (remember gluLookAt?)
//

void setCamera(float posX, float posY, float posZ,
	float lookAtX, float lookAtY, float lookAtZ) {

	float dir[3], right[3], up[3];

	up[0] = 0.0f;	up[1] = 1.0f;	up[2] = 0.0f;

	dir[0] = (lookAtX - posX);
	dir[1] = (lookAtY - posY);
	dir[2] = (lookAtZ - posZ);
	normalize(dir);

	crossProduct(dir, up, right);
	normalize(right);

	crossProduct(right, dir, up);
	normalize(up);

	float viewMatrix[16], aux[16];

	viewMatrix[0] = right[0];
	viewMatrix[4] = right[1];
	viewMatrix[8] = right[2];
	viewMatrix[12] = 0.0f;

	viewMatrix[1] = up[0];
	viewMatrix[5] = up[1];
	viewMatrix[9] = up[2];
	viewMatrix[13] = 0.0f;

	viewMatrix[2] = -dir[0];
	viewMatrix[6] = -dir[1];
	viewMatrix[10] = -dir[2];
	viewMatrix[14] = 0.0f;

	viewMatrix[3] = 0.0f;
	viewMatrix[7] = 0.0f;
	viewMatrix[11] = 0.0f;
	viewMatrix[15] = 1.0f;

	setTranslationMatrix(aux, -posX, -posY, -posZ);

	multMatrix(viewMatrix, aux);

	glBindBuffer(GL_UNIFORM_BUFFER, matricesUniBuffer);
	glBufferSubData(GL_UNIFORM_BUFFER, ViewMatrixOffset, MatrixSize, viewMatrix);
	glBindBuffer(GL_UNIFORM_BUFFER, 0);
}


// ------------------------------------------------------------
//
// Reshape Callback Function
//
float ratio;
void changeSize(int w, int h) {
	// Prevent a divide by zero, when window is too short
	// (you cant make a window of zero width).
	if (h == 0)
		h = 1;

	// Set the viewport to be the entire window
	glViewport(0, 0, w, h);

	ratio = (1.0f * w) / h;
	buildProjectionMatrix(35.0f, ratio, zNear, zFar);
}


// ------------------------------------------------------------
//
// Render stuff
//

// Render Assimp Model

void recursive_render(Model& model, const aiNode* nd) {
	// Get node transformation matrix
	aiMatrix4x4 m = nd->mTransformation;
	// OpenGL matrices are column major
	m.Transpose();

	// save model matrix and apply node transformation
	pushMatrix();

	float aux[16];
	memcpy(aux, &m, sizeof(float) * 16);
	multMatrix(modelMatrix, aux);
	setModelMatrix();

	// draw all meshes assigned to this node
	for (unsigned int n = 0; n < nd->mNumMeshes; ++n) {
		// bind material uniform
		glBindBufferRange(GL_UNIFORM_BUFFER, prog1.materialUniLoc, model.myMesh[nd->mMeshes[n]].uniformBlockIndex, 0, sizeof(struct MyMaterial));
		// bind texture
		glBindTexture(GL_TEXTURE_2D, model.myMesh[nd->mMeshes[n]].texIndex);
		// bind VAO
		glBindVertexArray(model.myMesh[nd->mMeshes[n]].vao);
		// draw
		glDrawElements(GL_TRIANGLES, model.myMesh[nd->mMeshes[n]].numFaces * 3, GL_UNSIGNED_INT, 0);
	}

	// draw all children
	for (unsigned int n = 0; n < nd->mNumChildren; ++n) {
		recursive_render(model, nd->mChildren[n]);
	}
	popMatrix();
}

ILuint imageID;
void saveScreenShot(char* fname) {
	imageID = ilGenImage();
	ilBindImage(imageID);
	ilutGLScreen();
	ilEnable(IL_FILE_OVERWRITE);
	ilSaveImage(fname);
	//ilDeleteImage(imageID);
}

void saveColorImage(GLuint fbo, const char* outFilename) {
	//allocate FreeImage memory
	int width = dmd_size[0], height = dmd_size[1];
	int oldFramebuffer;

	FIBITMAP *color_img = FreeImage_Allocate(width, height, 24);
	if (color_img == NULL) {
		printf("couldn't allocate color_img for saving!\n");
		return;
	}

	//save existing bound FBO
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);

	//bind desired FBO
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	glReadPixels(0, 0, width, height, GL_BGR, GL_UNSIGNED_BYTE, FreeImage_GetBits(color_img));

	//restore existing FBO
	glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);

	//write color_img
	FreeImage_Save(FreeImage_GetFIFFromFilename(outFilename), color_img, outFilename);

	//deallocate
	FreeImage_Unload(color_img);

	printf("Done saving color image\n");
}

void saveDepthImage(GLuint fbo, const char* outFilename) {
	//allocate FreeImage memory
	int width = dmd_size[0], height = dmd_size[1];
	int oldFramebuffer;

	float* depth_img = new float[width*height];
	//FIBITMAP *depth_img = FreeImage_Allocate(width, height, 32);
	if (depth_img == NULL) {
		printf("couldn't allocate depth_img for saving!\n");
		return;
	}

	//save existing bound FBO
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFramebuffer);

	//bind desired FBO
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	glReadPixels(0, 0, width, height, GL_DEPTH_COMPONENT, GL_FLOAT, depth_img);

	//restore existing FBO
	glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);


    


	//write depth_img
	//FreeImage_Save(FreeImage_GetFIFFromFilename(outFilename), depth_img, outFilename);


	//save and export depth map as MAT
	MATFile *pmat;
	mxArray *depthMat;

	pmat = matOpen(outFilename, "w");
	if (pmat == NULL) {
		printf("Error creating file %s\n", outFilename);
		return;
	}

	depthMat = mxCreateNumericMatrix(height, width, mxSINGLE_CLASS,mxREAL);
	if (depthMat == NULL) {
		printf("Unable to create mxArray.\n");
		return;
	}


	// linearize the depth_img and rearrange it
	// glReadPixels output depth from low left corner

	float* pointer;
	pointer = mxGetSingles(depthMat);
	float tem;
	float k1 = 2 * zFar * zNear / (zFar - zNear);
	float k2 = (zFar + zNear) / (zFar - zNear);
	
	
	for (int i=0; i < height; i++)
		for (int j = 0; j < width; j++)
		{
			tem = depth_img[(height - 1 - i)*width + j];
			tem = tem * 2 - 1;
			pointer[j*height + i] = -k1 / (tem - k2);
		}

	int status = matPutVariable(pmat,"DepthMap",depthMat);
	if (status != 0) {
		printf("Error saving mat\n");
		return;
	}
	 
	mxDestroyArray(depthMat);

	if (matClose(pmat) != 0) {
		printf("Error closing file %s\n", outFilename);
		return;
	}

	//printf("value: %f\n", depth_img[300]);

	//deallocate
	//FreeImage_Unload(depth_img);
	delete depth_img;
	printf("Done saving depth image\n");
}

void drawModels() {
	// set the model matrix to the identity Matrix
	for (int modelIter = 0; modelIter < NUM_MODELS; modelIter++) {
		setIdentityMatrix(modelMatrix, 4);
		translate(model[modelIter].translation[0], model[modelIter].translation[1], model[modelIter].translation[2]);
		rotate(model[modelIter].rotation[0], 1.0f, 0.0f, 0.0f);		// use our shader
		rotate(model[modelIter].rotation[1], 0.0f, 1.0f, 0.0f);		// use our shader
		rotate(model[modelIter].rotation[2], 0.0f, 0.0f, 1.0f);		// use our shader
		scale(model[modelIter].scaleFactor, model[modelIter].scaleFactor, model[modelIter].scaleFactor);
		recursive_render(model[modelIter], model[modelIter].scene->mRootNode);
	}
}

void savePosition() {
	// save position information for each model
	std::ofstream Position;
	std::string fname = data_folder_path + "/model_positions/Position.txt";
	Position.open(fname, std::ios::trunc);
	Position << "N " << NUM_MODELS << std::endl;
	
	for (int modelIter = 0; modelIter < NUM_MODELS; modelIter++) {
	
		Position << "M " << modelIter << std::endl;
		Position << "T " << model[modelIter].translation[0]<<" "<< model[modelIter].translation[1]<<" "<< model[modelIter].translation[2]<<std::endl;
		Position << "R " << model[modelIter].rotation[0] << " " << model[modelIter].rotation[1] << " " << model[modelIter].rotation[2] << std::endl;
		Position << "S " << model[modelIter].scaleFactor << std::endl;
	}

	Position <<"C " << r <<" "<<alpha <<" "<<beta<< std::endl;
	Position << "Z " << zFar << std::endl;
	Position.close();
}

Model *currModel = &model[0];
void usePosition() {
	FILE* fp;
	float x, y, z;
	int c1, c2;
	int mn;

	std::string fname = data_folder_path + "/model_positions/Position.txt";
	fp = fopen(fname.c_str(), "rb");

	if (fp == NULL) {
		printf("Error loading Position \n");
		exit(-1);
	}

	while (!feof(fp)) {
		c1 = fgetc(fp);
		

		while (!(c1 == 'M' || c1 == 'T' || c1 == 'R' || c1 == 'S' || c1 == 'C' || c1 == 'Z')) {
			c1 = fgetc(fp);
			if (feof(fp))
				break;
		}

		c2 = fgetc(fp);

		if ((c1 == 'M') && (c2 == ' ')) {
			fscanf(fp, "%d", &mn);
			currModel = &model[mn];
		}

		if ((c1 == 'T') && (c2 == ' ')) {
			fscanf(fp,"%f %f %f", &x,&y,&z);
			currModel->translation[0] = x;
			currModel->translation[1] = y;
			currModel->translation[2] = z;
		}

		if ((c1 == 'R') && (c2 == ' ')) {
			fscanf(fp, "%f %f %f", &x, &y, &z);
			currModel->rotation[0] = x;
			currModel->rotation[1] = y;
			currModel->rotation[2] = z;
		}

		if ((c1 == 'S') && (c2 == ' ')) {
			fscanf(fp, "%f", &x);
			currModel->scaleFactor = x;
		}

		if ((c1 == 'C') && (c2 == ' ')) {
			fscanf(fp, "%f %f %f", &x, &y, &z);
			r = x;
			alpha = y;
			beta = z;
         }

		if ((c1 == 'Z') && (c2 == ' ')) {
			fscanf(fp, "%f", &x);
			zFar = x;
		}
	}
	fclose(fp);
	currModel = &model[0];
}

void drawTextureToFramebuffer(int textureID) {
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, 1, 0, 1, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	glColor3f(1, 1, 1);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, textureID);
	glBegin(GL_QUADS);
	glTexCoord2f(0, 0); glVertex3f(0, 0, 0);
	glTexCoord2f(1, 0); glVertex3f(1, 0, 0);
	glTexCoord2f(1, 1); glVertex3f(1, 1, 0);
	glTexCoord2f(0, 1); glVertex3f(0, 1, 0);
	glEnd();
	glDisable(GL_TEXTURE_2D);
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
}

int slice_number = 0;
GLubyte slice_img[1920*1080*3];
float average_colors[8][3];
GLubyte px_value;
int nz_count;
void calculate_average_color() {
	glEnable(GL_TEXTURE_2D);

	for (int iters = 0; iters < PROG3_NUM_OUTPUT_TEXTURES; iters++) {
		glBindTexture(GL_TEXTURE_2D, prog3.tex_rgb[iters]);
		glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_UNSIGNED_BYTE, slice_img);

		for (int iterc = 0; iterc < 3; iterc++) {
			average_colors[iters][iterc] = 0.0;
		}

		for (int iterc = 0; iterc < 3; iterc++) {
			nz_count = 0;
			for (int iterx = 0; iterx < 1920; iterx++) {
				for (int itery = 0; itery < 1080; itery++) {
					px_value = slice_img[iterc + 3 * (iterx * 1080 + itery)*(sizeof(GLubyte))];
					if (px_value > 0) {
						nz_count++;
						average_colors[iters][iterc] += px_value;
					}
				}
			}
			average_colors[iters][iterc] = average_colors[iters][iterc] / nz_count;
		}
	}
		
	for (int iters = 0; iters < PROG3_NUM_OUTPUT_TEXTURES; iters++) {
		printf("Slice %d: %f %f %f\n", iters, average_colors[iters][0], average_colors[iters][1], average_colors[iters][2]);
	}

	glDisable(GL_TEXTURE_2D);
}

int imgCounter = 0;
char fname[1024], fname1[1024], fname2[1024];
float main_brightness[3] = { 0.41, 1.0, 0.11 };
bool useShaders = 1;
bool exec_program2 = 0; // synthetic.frag
bool vned = 0;
bool exec_program3 = vned; //voxelization.frag
bool exec_program4 = vned; //rgb2gray_slices.frag
bool exec_program5 = vned; //dithering.frag
bool exec_program6 = vned; //encoding.frag
bool exec_program7 = vned;
// Rendering Callback Function
void renderScene() {
	// Render program 1 (RGB and depth map of scene)
	{
		glBindFramebuffer(GL_FRAMEBUFFER, prog1.fbo_rgbd);
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		setCamera(camX, camY, camZ, 0, 0, 0);
		buildProjectionMatrix(35.0f, ratio, zNear, zFar);

		glUseProgram(prog1.program);
		// we are only going to use texture unit 0
		// unfortunately samplers can't reside in uniform blocks
		// so we have set this uniform separately
		//glUniform1i(texUnit, tex_background);

		//glutWireTeapot(2.0);
		drawModels();

		if (saveFramebufferOnce | saveFramebufferUntilStop) {
			//sprintf(fname, "%s/RGBD_data/trial_%02d_DepthMap.mat", data_folder_path.c_str(), imgCounter);
			sprintf(fname1, "%s/RGBD_data/trial_%02d_DepthMap.mat", data_folder_path.c_str(), imgCounter);
			sprintf(fname2, "%s/RGBD_data/trial_%02d_rgb.png", data_folder_path.c_str(), imgCounter);
			
			saveColorImage(prog1.fbo_rgbd, fname2);
			saveDepthImage(prog1.fbo_rgbd, fname1);
			imgCounter++;
			saveFramebufferOnce = false;
		}

		glPopAttrib();
	}

	// Render Program 2
	if(exec_program2)
	{
		glBindFramebuffer(GL_FRAMEBUFFER, prog2.fbo_rgb);
		glPushAttrib(GL_VIEWPORT_BIT);
		float fraction = 0.2;
		glViewport(dmd_size[0]*(1.0 - fraction)*0.5, dmd_size[1]*(1.0 - fraction)*0.5, dmd_size[0]*fraction, dmd_size[1]*fraction);

		//glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (useShaders == 0) { // Debugging
			glUseProgram(0);
			//drawTextureToFramebuffer(tex_background);
			drawTextureToFramebuffer(prog1.tex_depth);
			//drawTextureToFramebuffer(tex_rgb);
		}
		else { // Uses shaders
			glUseProgram(prog2.program);

			// Important that these two lines come after the glUseProgram() command
			glUniform1i(prog2.rgb_img, 0);
			glUniform1i(prog2.depth_map, 1);
			glEnable(GL_TEXTURE_2D);
			glActiveTexture(GL_TEXTURE0 + 0);
			glBindTexture(GL_TEXTURE_2D, prog1.tex_rgb);
			glActiveTexture(GL_TEXTURE0 + 1);
			glBindTexture(GL_TEXTURE_2D, prog1.tex_depth);

			glBindVertexArray(postprocess_VAO);
			glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
			glDisable(GL_TEXTURE_2D);
			// Important to set default active texture back to GL_TEXTURE0
			glActiveTexture(GL_TEXTURE0);
		}

		//if (saveFramebufferOnce | saveFramebufferUntilStop) {
		//	sprintf(fname2, "./outputs/synthetic_%02d_rgb.png", imgCounter);
		//	saveColorImage(prog2.fbo_rgb, fname2);
		//	imgCounter++;
		//	saveFramebufferOnce = false;
		//}

		glPopAttrib();
	}

	if (exec_program3)
	{
		glBindFramebuffer(GL_FRAMEBUFFER, prog3.fbo_rgb);
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		//glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (useShaders == 0) { // Debugging
			glUseProgram(0);
			//drawTextureToFramebuffer(tex_background);
			drawTextureToFramebuffer(prog1.tex_depth);
			//drawTextureToFramebuffer(tex_rgb);
		}
		else { // Uses shaders
			glUseProgram(prog3.program);

			glEnable(GL_TEXTURE_2D);
			glUniform1i(prog3.rgb_img, 0);
			glUniform1i(prog3.depth_map, 1);
			glUniform1f(prog3.zFar, zFar);
			glUniform1f(prog3.zNear, zNear);
			glActiveTexture(GL_TEXTURE0 + 0);
			glBindTexture(GL_TEXTURE_2D, prog1.tex_rgb);
			glActiveTexture(GL_TEXTURE0 + 1);
			glBindTexture(GL_TEXTURE_2D, prog1.tex_depth);

			glBindVertexArray(postprocess_VAO);
			glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

			//printf("%x, %x, %x \n", (average_color&0xFF0000)>>16, (average_color&0x00FF00)>>8, average_color&0x0000FF);
			//printf("%d, %d, %d \n", int(average_color[0]), int(average_color[1]), int(average_color[2]));

			// Important to set default active texture back to GL_TEXTURE0
			glActiveTexture(GL_TEXTURE0);
			glDisable(GL_TEXTURE_2D);
		}
		glPopAttrib();

		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glUseProgram(0);
		//calculate_average_color();
	}

	if (exec_program4)
	{
		glBindFramebuffer(GL_FRAMEBUFFER, prog4.fbo_gray);
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		//glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (useShaders == 0) { // Debugging
			glUseProgram(0);
			//drawTextureToFramebuffer(tex_background);
			drawTextureToFramebuffer(prog1.tex_depth);
			//drawTextureToFramebuffer(tex_rgb);
		}
		else { // Uses shaders
			glUseProgram(prog4.program);

			glUniform1f(prog4.brightness[0], main_brightness[0]);
			glUniform1f(prog4.brightness[1], main_brightness[1]);
			glUniform1f(prog4.brightness[2], main_brightness[2]);
			for (int iters = 0; iters < PROG3_NUM_OUTPUT_TEXTURES; iters++) {
				glUniform1i(prog4.rgb_img[iters], iters);
			}
			glEnable(GL_TEXTURE_2D);
			for (int iters = 0; iters < PROG3_NUM_OUTPUT_TEXTURES; iters++) {
				glActiveTexture(GL_TEXTURE0 + iters);
				glBindTexture(GL_TEXTURE_2D, prog3.tex_rgb[iters]);
			}


			glBindVertexArray(postprocess_VAO);
			glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

			// Important to set default active texture back to GL_TEXTURE0
			glActiveTexture(GL_TEXTURE0);
			glDisable(GL_TEXTURE_2D);
		}
		glPopAttrib();
	}	
	
	if (exec_program5)
	{
		glBindFramebuffer(GL_FRAMEBUFFER, prog5.fbo_binary);
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		//glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (useShaders == 0) { // Debugging
			glUseProgram(0);
			//drawTextureToFramebuffer(tex_background);
			drawTextureToFramebuffer(prog1.tex_depth);
			//drawTextureToFramebuffer(tex_rgb);
		}
		else { // Uses shaders
			glUseProgram(prog5.program);

			for (int iters = 0; iters < 8; iters++) {
				glUniform1i(prog5.gray_img[iters], iters);
			}
			glEnable(GL_TEXTURE_2D);
			for (int iters = 0; iters < 8; iters++) {
				glActiveTexture(GL_TEXTURE0 + iters);
				glBindTexture(GL_TEXTURE_2D, prog4.tex_gray[iters]);
			}

			glBindVertexArray(postprocess_VAO);
			glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

			// Important to set default active texture back to GL_TEXTURE0
			glActiveTexture(GL_TEXTURE0);
			glDisable(GL_TEXTURE_2D);
		}
		glPopAttrib();
	}	

	if (exec_program6)
	{
		glBindFramebuffer(GL_FRAMEBUFFER, prog6.fbo_encoded);
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		//glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		if (useShaders == 0) { // Debugging
			glUseProgram(0);
			//drawTextureToFramebuffer(tex_background);
			drawTextureToFramebuffer(prog1.tex_depth);
			//drawTextureToFramebuffer(tex_rgb);
		}
		else { // Uses shaders
			glUseProgram(prog6.program);

			for (int iters = 0; iters < 8; iters++) {
				glUniform1i(prog6.binary_img[iters], iters);
			}
			glEnable(GL_TEXTURE_2D);
			for (int iters = 0; iters < 8; iters++) {
				glActiveTexture(GL_TEXTURE0 + iters);
				//glBindTexture(GL_TEXTURE_2D, prog4.tex_gray[iters]);
				glBindTexture(GL_TEXTURE_2D, prog5.tex_binary[iters]);
			}

			glBindVertexArray(postprocess_VAO);
			glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

			// Important to set default active texture back to GL_TEXTURE0
			glActiveTexture(GL_TEXTURE0);
			glDisable(GL_TEXTURE_2D);
		}

		//if (saveFramebufferOnce | saveFramebufferUntilStop) {
		//	sprintf(fname2, "./outputs/encoded_%02d.png", imgCounter);
		//	saveColorImage(prog6.fbo_encoded, fname2);
		//	imgCounter++;
		//	saveFramebufferOnce = false;
		//}

		glPopAttrib();

	}


	// Render to screen or display
	if (exec_program7) {
		glBindFramebuffer(GL_FRAMEBUFFER, prog7.fbo);
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		glUseProgram(prog7.program);
		glEnable(GL_TEXTURE_2D);
		glUniform1i(prog7.rgb_img, 0);
		if (exec_program2) {
			glBindTexture(GL_TEXTURE_2D, prog2.tex_rgb);
		}
		else if (exec_program3 && !exec_program4) {
			if (slice_number > 1) {
				glBindTexture(GL_TEXTURE_2D, prog3.tex_rgb[1]);
			}
			else {
				glBindTexture(GL_TEXTURE_2D, prog3.tex_rgb[slice_number]);
			}
		}
		else if (exec_program4 && !exec_program5) {
			glBindTexture(GL_TEXTURE_2D, prog4.tex_gray[slice_number]);
		}
		else if (exec_program5 && !exec_program6) {
			glBindTexture(GL_TEXTURE_2D, prog5.tex_binary[slice_number]);
		}
		else if (exec_program6) {
			glBindTexture(GL_TEXTURE_2D, prog6.tex_encoded);
		}
		else {
			glBindTexture(GL_TEXTURE_2D, prog1.tex_depth);
		}

		glBindVertexArray(postprocess_VAO);
		glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

		// Important to set default active texture back to GL_TEXTURE0
		glActiveTexture(GL_TEXTURE0);
		glDisable(GL_TEXTURE_2D);

		if (saveFramebufferOnce | saveFramebufferUntilStop) {
			sprintf(fname2, "./outputs/currentFrameBuffer_%02d.png", imgCounter);
			saveColorImage(prog7.fbo, fname2);
			imgCounter++;
			saveFramebufferOnce = false;
		}

		glPopAttrib();

	} 
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	if (display_on_device) {
		glPushAttrib(GL_VIEWPORT_BIT);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);
		glUseProgram(0);
		drawTextureToFramebuffer(tex_background);
		glPopAttrib();
	}
	else {
		glPushAttrib(GL_VIEWPORT_BIT);
		glUseProgram(0);
		glViewport(0, 0, dmd_size[0], dmd_size[1]);

		if (exec_program2) {
			drawTextureToFramebuffer(prog2.tex_rgb);
		}
		else if (exec_program3 && !exec_program4) {
			if (slice_number > 1) {
				drawTextureToFramebuffer(prog3.tex_rgb[1]);
			}
			else {
				drawTextureToFramebuffer(prog3.tex_rgb[slice_number]);
			}
		}
		else if (exec_program4 && !exec_program5) {
			drawTextureToFramebuffer(prog4.tex_gray[slice_number]);
		}
		else if (exec_program5 && !exec_program6) {
			drawTextureToFramebuffer(prog5.tex_binary[slice_number]);
		}
		else if (exec_program6) {
			drawTextureToFramebuffer(prog6.tex_encoded);
		}
		else if (exec_program7) {
			drawTextureToFramebuffer(prog7.tex);
		}
		else {
			drawTextureToFramebuffer(prog1.tex_rgb);
		}
		glPopAttrib();
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glUseProgram(0);

	// swap buffers
	glutSwapBuffers();

	// FPS computation and display
	frame++;
	time_fps = glutGet(GLUT_ELAPSED_TIME);
	if (time_fps - timebase > 1000) {
		sprintf(s, "FPS: %4.2f %d", frame*1000.0 / (time_fps - timebase), frame);
		timebase = time_fps;
		frame = 0;
		glutSetWindowTitle(s);
	}
}

int modify_valuei(int value, int delta, int min_value, int max_value) {
	value = value + delta;
	if (value < min_value) {
		value = min_value;
	}

	if (value > max_value) {
		value = max_value;
	}

	return value;
}

void print_valuei(int value, char name[]) {
	printf("%s: %d \n", name, value);
}

float modify_valuef(float value, float delta, float min_value, float max_value) {
	value = value + delta;
	if (value < min_value) {
		value = min_value;
	}

	if (value > max_value) {
		value = max_value;
	}

	return value;
}

void updateCamVariables() {
	camX = r * sin(alpha * 3.14f / 180.0f) * cos(beta * 3.14f / 180.0f);
	camZ = r * cos(alpha * 3.14f / 180.0f) * cos(beta * 3.14f / 180.0f);
	camY = r *   						     sin(beta * 3.14f / 180.0f);

	// set camera matrix
	setCamera(camX, camY, camZ, 0, 0, 0);

}


// ------------------------------------------------------------
//
// Events from the Keyboard
//
float stepSize = 0.025;
int keymapmode = 2;
void processKeys(unsigned char key, int xx, int yy) {

	if (key == '`') {
		keymapmode = (keymapmode++) % 4;
		printf("keymapmode: %d \n", keymapmode);
	}
	else {
		if (keymapmode == 2) { // Adjusting 3d models
			/*
			Remaining letters:
			    5678  
			       io 
			a     j  
			       
			*/

			switch (key) {
			case 27: { glutLeaveMainLoop(); break; }
			case 'z': r -= 0.1f; break;
			case 'x': r += 0.1f; break;
			case 'm': glEnable(GL_MULTISAMPLE); break;
			case 'M': glDisable(GL_MULTISAMPLE); break;
			case '1': currModel = &model[0]; printf("Current Model is 1 \n"); break;
			case '2': currModel = &model[1]; printf("Current Model is 2 \n"); break;
			case '3': currModel = &model[2]; printf("Current Model is 2 \n"); break;
			case '4': currModel = &model[3]; printf("Current Model is 3 \n"); break;
			case '9': stepSize = stepSize / 3.0; printf("stepSize = %f\n", stepSize);  break;
			case '0': stepSize = stepSize * 3.0; printf("stepSize = %f\n", stepSize); break;
			case 's': saveFramebufferOnce = true; printf("Saving framebuffer \n"); break;
			case 'S': {
						  saveFramebufferUntilStop = !saveFramebufferUntilStop;
						  if (saveFramebufferUntilStop) {
							  printf("Saving framebuffer until stop. Press S again to stop \n");
						  }
						  else {
							  printf("Stoped saving \n");
						  }
						  break;
			}
			case 'q': {
						  currModel->scaleFactor -= 0.005f*stepSize;
						  if (currModel->scaleFactor < 0.005)
							  currModel->scaleFactor = 0.005;
						  printf("currModel->scaleFactor: %f\n", currModel->scaleFactor);
						  break;

			}
			case 'w': {
						  currModel->scaleFactor += 0.005f*stepSize;
						  printf("currModel->scaleFactor: %f\n", currModel->scaleFactor);
						  break;
			}
			case 'e': currModel->rotation[0] -= stepSize; printf("currModel->rotation[0]: %f \n", currModel->rotation[0]); break;
			case 'r': currModel->rotation[0] += stepSize; printf("currModel->rotation[0]: %f \n", currModel->rotation[0]); break;
			case 'd': currModel->rotation[1] -= stepSize; printf("currModel->rotation[1]: %f \n", currModel->rotation[1]); break;
			case 'f': currModel->rotation[1] += stepSize; printf("currModel->rotation[1]: %f \n", currModel->rotation[1]); break;
			case 'c': currModel->rotation[2] -= stepSize; printf("currModel->rotation[2]: %f \n", currModel->rotation[2]); break;
			case 'v': currModel->rotation[2] += stepSize; printf("currModel->rotation[2]: %f \n", currModel->rotation[2]); break;
			case 't': currModel->translation[0] -= stepSize; printf("currModel->translation[0]: %f \n", currModel->translation[0]);break;
			case 'y': currModel->translation[0] += stepSize; printf("currModel->translation[0]: %f \n", currModel->translation[0]);break;
			case 'g': currModel->translation[1] -= stepSize; printf("currModel->translation[1]: %f \n", currModel->translation[1]);break;
			case 'h': currModel->translation[1] += stepSize; printf("currModel->translation[1]: %f \n", currModel->translation[1]);break;
			case 'b': currModel->translation[2] -= stepSize; printf("currModel->translation[2]: %f \n", currModel->translation[2]);break;
			case 'n': currModel->translation[2] += stepSize; printf("currModel->translation[2]: %f \n", currModel->translation[2]);break;
			case 'p': savePosition(); printf("Saving Position Information \n"); break;
			case 'u': usePosition(); break;
			case 'k': zFar = modify_valuef(zFar, -0.1, zNear, 200.0); printf("zFar: %f \n", zFar); break;
			case 'l': zFar = modify_valuef(zFar, 0.1, zNear, 200.0); printf("zFar: %f \n", zFar); break;
			case 'i': zNear = modify_valuef(zNear, -0.1, 0.1, 200.0); printf("zNear: %f \n", zNear); break;
			case 'o': zNear = modify_valuef(zNear, 0.1, 0.1, 200.0); printf("zNear: %f \n", zNear); break;
			}
			updateCamVariables();
		}
		else if (keymapmode == 3) {
			switch (key) {
			case 27: { glutLeaveMainLoop(); break; }
			case 'q': main_brightness[0] = modify_valuef(main_brightness[0], -0.01, 0.1, 1.0); printf("brightness: %f %f %f \n", main_brightness[0], main_brightness[1], main_brightness[2]); break;
			case 'w': main_brightness[0] = modify_valuef(main_brightness[0], +0.01, 0.1, 1.0); printf("brightness: %f %f %f \n", main_brightness[0], main_brightness[1], main_brightness[2]); break;
			case 'a': main_brightness[1] = modify_valuef(main_brightness[1], -0.01, 0.1, 1.0); printf("brightness: %f %f %f \n", main_brightness[0], main_brightness[1], main_brightness[2]); break;
			case 's': main_brightness[1] = modify_valuef(main_brightness[1], +0.01, 0.1, 1.0); printf("brightness: %f %f %f \n", main_brightness[0], main_brightness[1], main_brightness[2]); break;
			case 'z': main_brightness[2] = modify_valuef(main_brightness[2], -0.01, 0.1, 1.0); printf("brightness: %f %f %f \n", main_brightness[0], main_brightness[1], main_brightness[2]); break;
			case 'x': main_brightness[2] = modify_valuef(main_brightness[2], +0.01, 0.1, 1.0); printf("brightness: %f %f %f \n", main_brightness[0], main_brightness[1], main_brightness[2]); break;
			case '5': slice_number = modify_valuei(slice_number, -1, 0, 7); print_valuei(slice_number, "slice_number"); break;
			case '6': slice_number = modify_valuei(slice_number, +1, 0, 7); print_valuei(slice_number, "slice_number"); break;
			default: printf("Entered key does nothing \n");
			}
		}
	}

	//  uncomment this if not using an idle func
	//	glutPostRedisplay();
}

// ------------------------------------------------------------
//
// Mouse Events
//

void processMouseButtons(int button, int state, int xx, int yy) {
	// start tracking the mouse
	if (state == GLUT_DOWN) {
		startX = xx;
		if (button == GLUT_LEFT_BUTTON)
			tracking = 1;
	}

	//stop tracking the mouse
	else if (state == GLUT_UP) {
		//if (tracking == 1) {
		//	alpha = (startX - xx);
		//	for (int iterm = 0; iterm < NUM_MODELS; iterm++) {
		//		model[iterm].rotation[1] = alpha;
		//	}
		//}
		tracking = 0;
	}
}

// Track mouse motion while buttons are pressed
void processMouseMotion(int xx, int yy) {

	int deltaX;
	float alphaAux;

	deltaX = startX - xx;
	startX = xx;

	// left mouse button: move camera
	if (tracking == 1) {
		model[0].rotation[1] -= deltaX*stepSize;
		model[1].rotation[2] -= deltaX*stepSize;
	}
	//  uncomment this if not using an idle func
	//	glutPostRedisplay();
}

//void processMouseButtons(int button, int state, int xx, int yy) {
//	// start tracking the mouse
//	if (state == GLUT_DOWN) {
//		startX = xx;
//		startY = yy;
//		if (button == GLUT_LEFT_BUTTON)
//			tracking = 1;
//		else if (button == GLUT_RIGHT_BUTTON)
//			tracking = 2;
//	}
//
//	//stop tracking the mouse
//	else if (state == GLUT_UP) {
//		if (tracking == 1) {
//			alpha += (startX - xx);
//			beta += (yy - startY);
//		}
//		else if (tracking == 2) {
//			r += (yy - startY) * 0.01f;
//		}
//		tracking = 0;
//	}
//}
//
//// Track mouse motion while buttons are pressed
//void processMouseMotion(int xx, int yy) {
//
//	int deltaX, deltaY;
//	float alphaAux, betaAux;
//	float rAux;
//
//	deltaX = startX - xx;
//	deltaY = yy - startY;
//
//	// left mouse button: move camera
//	if (tracking == 1) {
//		alphaAux = alpha + deltaX;
//		betaAux = beta + deltaY;
//
//		if (betaAux > 85.0f)
//			betaAux = 85.0f;
//		else if (betaAux < -85.0f)
//			betaAux = -85.0f;
//		rAux = r;
//
//		camX = rAux * cos(betaAux * 3.14f / 180.0f) * sin(alphaAux * 3.14f / 180.0f);
//		camZ = rAux * cos(betaAux * 3.14f / 180.0f) * cos(alphaAux * 3.14f / 180.0f);
//		camY = rAux * sin(betaAux * 3.14f / 180.0f);
//	}
//	// right mouse button: zoom
//	else if (tracking == 2) {
//
//		alphaAux = alpha;
//		betaAux = beta;
//		rAux = r + (deltaY * 0.01f);
//
//		camX = rAux * cos(betaAux * 3.14f / 180.0f) * sin(alphaAux * 3.14f / 180.0f);
//		camZ = rAux * cos(betaAux * 3.14f / 180.0f) * cos(alphaAux * 3.14f / 180.0f);
//		camY = rAux * sin(betaAux * 3.14f / 180.0f);
//	}
//	//  uncomment this if not using an idle func
//	//	glutPostRedisplay();
//}
//
void mouseWheel(int wheel, int direction, int x, int y) {
	r += direction * 0.1f;
	updateCamVariables();
}

// ------------------------------------------------------------
//
// Model loading and OpenGL setup
//

const GLfloat light_ambient[] = { 0.0f, 0.0f, 0.0f, 1.0f };
const GLfloat light_diffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
const GLfloat light_specular[] = { 1.0f, 1.0f, 1.0f, 1.0f };
const GLfloat light_position[] = { 2.0f, 5.0f, 5.0f, 0.0f };

const GLfloat mat_ambient[] = { 0.7f, 0.7f, 0.7f, 1.0f };
const GLfloat mat_diffuse[] = { 0.8f, 0.8f, 0.8f, 1.0f };
const GLfloat mat_specular[] = { 1.0f, 1.0f, 1.0f, 1.0f };
const GLfloat high_shininess[] = { 100.0f };

void loadTexture(const char* lpszPathName, GLuint tex) {
	FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;

	fif = FreeImage_GetFileType(lpszPathName, 0);
	if (fif == FIF_UNKNOWN) {
		fif = FreeImage_GetFIFFromFilename(lpszPathName);
	}

	if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsReading(fif)) {
		FIBITMAP *image = FreeImage_Load(fif, lpszPathName, 0);
		if (image != NULL) {
			//convert to 32-bpp so things will be properly aligned 
			FIBITMAP* temp = image;
			image = FreeImage_ConvertTo32Bits(image);
			FreeImage_Unload(temp);

			glBindTexture(GL_TEXTURE_2D, tex);
			glPixelStorei(GL_UNPACK_ROW_LENGTH, FreeImage_GetPitch(image) / 4);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FreeImage_GetWidth(image), FreeImage_GetHeight(image), 0, GL_BGRA, GL_UNSIGNED_BYTE, FreeImage_GetBits(image));
			FreeImage_Unload(image);
		}
		else {
			printf("error reading image '%s', exiting...\n", lpszPathName);
			exit(1);
		}
	}
	else {
		printf("missing/unknown/unsupported image '%s', exiting...\n", lpszPathName);
		exit(1);
	}
}

int init() {
	/* initialization of DevIL */
	ilInit();

	for (int modelIter = 0; modelIter < NUM_MODELS; modelIter++) {
		model[modelIter].basepath = data_folder_path + "/" +  file_path_and_name[modelIter][0];
		model[modelIter].modelname = file_path_and_name[modelIter][1];
		if (!model[modelIter].Import3DFromFile())
			return(0);
		model[modelIter].LoadGLTextures();
	}

	glGetUniformBlockIndex = (PFNGLGETUNIFORMBLOCKINDEXPROC)glutGetProcAddress("glGetUniformBlockIndex");
	glUniformBlockBinding = (PFNGLUNIFORMBLOCKBINDINGPROC)glutGetProcAddress("glUniformBlockBinding");
	glGenVertexArrays = (PFNGLGENVERTEXARRAYSPROC)glutGetProcAddress("glGenVertexArrays");
	glBindVertexArray = (PFNGLBINDVERTEXARRAYPROC)glutGetProcAddress("glBindVertexArray");
	glBindBufferRange = (PFNGLBINDBUFFERRANGEPROC)glutGetProcAddress("glBindBufferRange");
	glDeleteVertexArrays = (PFNGLDELETEVERTEXARRAYSPROC)glutGetProcAddress("glDeleteVertexArrays");

	glEnable(GL_DEPTH_TEST);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

	//char fileName[1024] = "background.png";
	char fileName[1024] = "white1.png";
	glGenTextures(1, &tex_background);
	glBindTexture(GL_TEXTURE_2D, tex_background);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	loadTexture(fileName, tex_background);

	//
	// Uniform Block. Must declare this before calling prog1.delayed_init()
	//
	glGenBuffers(1, &matricesUniBuffer);
	glBindBuffer(GL_UNIFORM_BUFFER, matricesUniBuffer);
	glBufferData(GL_UNIFORM_BUFFER, MatricesUniBufferSize, NULL, GL_DYNAMIC_DRAW);
	glBindBufferRange(GL_UNIFORM_BUFFER, prog1.matricesUniLoc, matricesUniBuffer, 0, MatricesUniBufferSize);	//setUniforms();
	glBindBuffer(GL_UNIFORM_BUFFER, 0);

	// Must declare this before prog2.delayed_init()
	glGenVertexArrays(1, &postprocess_VAO);
	glGenBuffers(1, &postprocess_VBO);
	glGenBuffers(1, &postprocess_EBO);

	prog1.delayed_init();
	prog2.delayed_init();
	prog3.delayed_init();
	prog4.delayed_init();
	prog5.delayed_init();
	prog6.delayed_init();
	prog7.delayed_init();

	glBindRenderbuffer(GL_RENDERBUFFER, 0);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);

	//glEnable(GL_LIGHT0);
	//glEnable(GL_NORMALIZE);
	//glEnable(GL_COLOR_MATERIAL);
	//glEnable(GL_LIGHTING);

	//glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
	//glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
	//glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
	//glLightfv(GL_LIGHT0, GL_POSITION, light_position);

	//glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
	//glMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);
	//glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
	//glMaterialfv(GL_FRONT, GL_SHININESS, high_shininess);

	glEnable(GL_MULTISAMPLE);

	return true;
}


// ------------------------------------------------------------
//
// Main function
//
int main(int argc, char **argv) {
	//  GLUT initialization
	glutInit(&argc, argv);

	glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA | GLUT_MULTISAMPLE);

	//glutInitContextVersion(3, 3);
	//glutInitContextFlags(GLUT_COMPATIBILITY_PROFILE);

	if (display_on_device) {
		printf("%d %d \n", window_position[0], window_position[1]);
		printf("%d %d \n", window_size[0], window_size[1]);
		glutInitWindowPosition(window_position[0], window_position[1]);
		glutInitWindowSize(window_size[0], window_size[1]);
	}
	else {
		glutInitWindowPosition(100, 100);
		glutInitWindowSize(dmd_size[0], dmd_size[1]);
	}
	glutCreateWindow("Varifocal Occlusion");

	//  Callback Registration
	glutDisplayFunc(renderScene);
	glutReshapeFunc(changeSize);
	glutIdleFunc(renderScene);

	//	Mouse and Keyboard Callbacks
	glutKeyboardFunc(processKeys);
	glutMouseFunc(processMouseButtons);
	glutMotionFunc(processMouseMotion);

	glutMouseWheelFunc(mouseWheel);

	//	Init GLEW
	//glewExperimental = GL_TRUE;
	glewInit();
	if (glewIsSupported("GL_VERSION_3_3"))
		printf("Ready for OpenGL 3.3\n");
	else {
		printf("OpenGL 3.3 not supported\n");
		return(1);
	}

	//  Init the app (load model and textures) and OpenGL
	if (!init())
		printf("Could not Load the Model\n");

	printf("Vendor: %s\n", glGetString(GL_VENDOR));
	printf("Renderer: %s\n", glGetString(GL_RENDERER));
	printf("Version: %s\n", glGetString(GL_VERSION));
	printf("GLSL: %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));

	// return from main loop
	glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_GLUTMAINLOOP_RETURNS);

	//usePosition();
	//updateCamVariables();
	//  GLUT main loop
	glutMainLoop();

	// delete buffers
	glDeleteBuffers(1, &matricesUniBuffer);
	return(0);
}

