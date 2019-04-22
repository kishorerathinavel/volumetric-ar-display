#include "program6.h"

program6_class::program6_class() {
	// Shader Names
	this->fname_vertex_shader = "synthetic1.vert";
	this->fname_fragment_shader = "encoding.frag";
}

program6_class::~program6_class() {
	glDeleteFramebuffers(1, &this->fbo_encoded);
}

void program6_class::delayed_init() {
	this->program = this->setup_shaders();
	this->genVAOs();

	glGenTextures(1, &this->tex_encoded);
	glBindTexture(GL_TEXTURE_2D, this->tex_encoded);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, dmd_size[0], dmd_size[1], 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
	glBindTexture(GL_TEXTURE_2D, 0);

	glGenFramebuffers(1, &this->fbo_encoded);
	glBindFramebuffer(GL_FRAMEBUFFER, this->fbo_encoded);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, this->tex_encoded, 0);

	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (status != GL_FRAMEBUFFER_COMPLETE) {
		printf("Error in creating framebuffer \n");
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void program6_class::genVAOs() {
	glBindVertexArray(postprocess_VAO);

	glBindBuffer(GL_ARRAY_BUFFER, postprocess_VBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(postprocess_vertices), postprocess_vertices, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, postprocess_EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(postprocess_indices), postprocess_indices, GL_STATIC_DRAW);

	// position attribute
	glVertexAttribPointer(this->vertexLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(this->vertexLoc);
	// texture coord attribute
	glVertexAttribPointer(this->textureLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
	glEnableVertexAttribArray(this->textureLoc);
}

GLuint program6_class::setup_shaders() {
	char *vs = NULL, *fs = NULL, *fs2 = NULL;

	GLuint p, v, f;

	v = glCreateShader(GL_VERTEX_SHADER);
	f = glCreateShader(GL_FRAGMENT_SHADER);


	vs = textFileRead(this->fname_vertex_shader);
	fs = textFileRead(this->fname_fragment_shader);

	const char * vv = vs;
	const char * ff = fs;

	glShaderSource(v, 1, &vv, NULL);
	glShaderSource(f, 1, &ff, NULL);

	free(vs); free(fs);

	glCompileShader(v);
	glCompileShader(f);

	printShaderInfoLog(f);
	printShaderInfoLog(v);

	p = glCreateProgram();
	glAttachShader(p, v);
	glAttachShader(p, f);

	glBindAttribLocation(p, this->vertexLoc, "position");
	glBindAttribLocation(p, this->textureLoc, "texCoord");
	glBindFragDataLocation(p, 0, "FragColor");

	glLinkProgram(p);
	glValidateProgram(p);
	printProgramInfoLog(p);

	this->program = p;
	this->vertexShader = v;
	this->fragmentShader = f;

	this->binary_img[0] = glGetUniformLocation(this->program, "binary_img[0]");
	this->binary_img[1] = glGetUniformLocation(this->program, "binary_img[1]");
	this->binary_img[2] = glGetUniformLocation(this->program, "binary_img[2]");
	this->binary_img[3] = glGetUniformLocation(this->program, "binary_img[3]");
	this->binary_img[4] = glGetUniformLocation(this->program, "binary_img[4]");
	this->binary_img[5] = glGetUniformLocation(this->program, "binary_img[5]");
	this->binary_img[6] = glGetUniformLocation(this->program, "binary_img[6]");
	this->binary_img[7] = glGetUniformLocation(this->program, "binary_img[7]");

	return(p);
}


