#version 330

out vec4 FragColor;

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform sampler2D rgb_img;
uniform int bitplane;

void main() {
  vec4 rgb_value = texture(rgb_img, TexCoord);
  vec4 FragColor = vec4(rgb_value[bitplane/8], rgb_value[bitplane/8], rgb_value[bitplane/8], 1.0);
}
