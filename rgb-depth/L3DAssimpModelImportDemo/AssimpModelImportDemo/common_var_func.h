#pragma once

#include <GL/glew.h>
#include <GL/freeglut.h>
#include "textfile.h"
#include <windows.h>
#include <fstream>
#include <iostream>
#include <vector>
#include <map>
#include <math.h>
#include <string>

// include DevIL for image loading
#include <IL\il.h>
#include <IL\ilut.h>

// assimp include files. These three are usually needed.
#include "assimp/Importer.hpp"	//OO version Header!
#include "assimp/PostProcess.h"
#include "assimp/Scene.h"

#include <FreeImage.h>

extern int dmd_size[2];
extern float postprocess_vertices[20];
extern unsigned int postprocess_indices[6];
extern unsigned int postprocess_VBO, postprocess_VAO, postprocess_EBO;

// --------------------------------------------------------
//
// Shader Stuff
//

void printShaderInfoLog(GLuint obj);
void printProgramInfoLog(GLuint obj);

