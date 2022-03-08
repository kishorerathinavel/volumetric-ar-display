#version 330

out vec4 FragColor;

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform sampler2D rgb_img;
uniform sampler2D depth_map;

void main() {
  if(TexCoord.x < 1.0/8.0) {
    FragColor = vec4(1.0/256.0);
  } 
  else if (TexCoord.x < 2.0/8.0) {
	FragColor = vec4(1.0/128.0);
  } 
  else if (TexCoord.x < 3.0/8.0) {
	FragColor = vec4(1.0/64.0);
  }
  else if (TexCoord.x < 4.0/8.0) {
	FragColor = vec4(1.0/32.0);
  }
  else if (TexCoord.x < 5.0/8.0) {
	FragColor = vec4(1.0/16.0);
  }
  else if (TexCoord.x < 6.0/8.0) {
	FragColor = vec4(1.0/8.0);
  }
  else if (TexCoord.x < 7.0/8.0) {
	FragColor = vec4(1.0/4.0);
  } 
  else {
    FragColor = vec4(128.0/255.0);
  }
}
