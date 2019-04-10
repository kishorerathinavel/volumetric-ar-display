#version 330

out vec4 FragColor;

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform sampler2D rgb_img;
uniform sampler2D depth_map;

void main() {
  if(TexCoord.x < 0.5) {
    FragColor = vec4(1.0);
  }
  else {
    FragColor = vec4(0.5);
  }
}
