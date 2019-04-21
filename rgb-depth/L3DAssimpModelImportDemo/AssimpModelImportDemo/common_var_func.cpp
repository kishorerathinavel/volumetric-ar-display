#include "common_var_func.h"

int dmd_size[] = { 1920, 1080 };
unsigned int postprocess_VBO = 0;
unsigned int postprocess_VAO = 1;
unsigned int postprocess_EBO = 2;

// --------------------------------------------------------
//
// Shader Stuff
//
float postprocess_vertices[] ={
	// positions     // texture coords
	1.0f, 1.0f, 0.0f, 1.0f, 1.0f, // top right
	1.0f, 0.0f, 0.0f, 1.0f, 0.0f, // bottom right
	0.0f, 0.0f, 0.0f, 0.0f, 0.0f, // bottom left
	0.0f, 1.0f, 0.0f, 0.0f, 1.0f  // top left 
};

unsigned int postprocess_indices[] ={
	0, 1, 3, // first triangle
	1, 2, 3  // second triangle
};


void printShaderInfoLog(GLuint obj)
{
	int infologLength = 0;
	int charsWritten = 0;
	char *infoLog;

	glGetShaderiv(obj, GL_INFO_LOG_LENGTH, &infologLength);

	if (infologLength > 0)
	{
		infoLog = (char *)malloc(infologLength);
		glGetShaderInfoLog(obj, infologLength, &charsWritten, infoLog);
		printf("%s\n", infoLog);
		free(infoLog);
	}
}


void printProgramInfoLog(GLuint obj)
{
	int infologLength = 0;
	int charsWritten = 0;
	char *infoLog;

	glGetProgramiv(obj, GL_INFO_LOG_LENGTH, &infologLength);

	if (infologLength > 0)
	{
		infoLog = (char *)malloc(infologLength);
		glGetProgramInfoLog(obj, infologLength, &charsWritten, infoLog);
		printf("%s\n", infoLog);
		free(infoLog);
	}
}



