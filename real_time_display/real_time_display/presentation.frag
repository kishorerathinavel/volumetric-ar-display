#version 330

out vec4 FragColor;
in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform	sampler2D rgb_img;

void main() {
  //FragColor = vec4(1.0);
  FragColor = texture(rgb_img, TexCoord);
}
