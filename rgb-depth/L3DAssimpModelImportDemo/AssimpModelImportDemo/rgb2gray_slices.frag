#version 330

out vec4 FragColor[8];

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform	sampler2D rgb_img[2];

void main() {
  vec4 rgb_color0 = texture(rgb_img[0], TexCoord);
  vec4 rgb_color1 = texture(rgb_img[1], TexCoord);
  FragColor[0] = vec4(vec3(rgb_color0[0]), 1.0);
  FragColor[1] = vec4(vec3(rgb_color0[1]), 1.0);
  FragColor[2] = vec4(vec3(rgb_color0[2]), 1.0);
  FragColor[3] = vec4(vec3(0.0), 1.0);
  FragColor[4] = vec4(vec3(0.0), 1.0);
  FragColor[5] = vec4(vec3(rgb_color1[0]), 1.0);
  FragColor[6] = vec4(vec3(rgb_color1[1]), 1.0);
  FragColor[7] = vec4(vec3(rgb_color1[2]), 1.0);
}
