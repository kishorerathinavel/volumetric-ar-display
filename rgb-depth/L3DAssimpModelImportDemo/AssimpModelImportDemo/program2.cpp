#include "program2.h"

program2_class::program2_class() {
	// Shader Names
	this->fname_synthetic1_vertex_shader = "synthetic1.vert";
	this->fname_synthetic1_fragment_shader = "synthetic1.frag";
}

program2_class::~program2_class() {
	glDeleteFramebuffers(1, &this->fbo_synthetic1_rgb);
}

void program2_class::delayed_init() {
	this->program2 = this->setup_shaders();
	this->genVAOs();

	glGenTextures(1, &this->tex_synthetic1_rgb);
	glBindTexture(GL_TEXTURE_2D, this->tex_synthetic1_rgb);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, dmd_size[0], dmd_size[1], 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
	glBindTexture(GL_TEXTURE_2D, 0);

	glGenFramebuffers(1, &this->fbo_synthetic1_rgb);
	glBindFramebuffer(GL_FRAMEBUFFER, this->fbo_synthetic1_rgb);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, this->tex_synthetic1_rgb, 0);

	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (status != GL_FRAMEBUFFER_COMPLETE) {
		printf("Error in creating framebuffer \n");
	}
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void program2_class::genVAOs() {
	glBindVertexArray(postprocess_VAO);

	glBindBuffer(GL_ARRAY_BUFFER, postprocess_VBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(postprocess_vertices), postprocess_vertices, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, postprocess_EBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(postprocess_indices), postprocess_indices, GL_STATIC_DRAW);

	// position attribute
	glVertexAttribPointer(this->synthetic1_vertexLoc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(this->synthetic1_vertexLoc);
	// texture coord attribute
	glVertexAttribPointer(this->synthetic1_textureLoc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
	glEnableVertexAttribArray(this->synthetic1_textureLoc);
}

GLuint program2_class::setup_shaders() {
	char *vs = NULL, *fs = NULL, *fs2 = NULL;

	GLuint p, v, f;

	v = glCreateShader(GL_VERTEX_SHADER);
	f = glCreateShader(GL_FRAGMENT_SHADER);


	vs = textFileRead(this->fname_synthetic1_vertex_shader);
	fs = textFileRead(this->fname_synthetic1_fragment_shader);

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

	glBindAttribLocation(p, this->synthetic1_vertexLoc, "position");
	glBindAttribLocation(p, this->synthetic1_textureLoc, "texCoord");
	glBindFragDataLocation(p, 0, "FragColor");

	glLinkProgram(p);
	glValidateProgram(p);
	printProgramInfoLog(p);

	this->program2 = p;
	this->synthetic1_vertexShader = v;
	this->synthetic1_fragmentShader = f;

	this->synthetic1_rgb_img = glGetUniformLocation(this->program2, "rgb_img");
	this->synthetic1_depth_map = glGetUniformLocation(this->program2, "depth_map");

	return(p);
}


