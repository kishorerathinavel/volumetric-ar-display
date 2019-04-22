#version 330

out vec4 FragColor[8];

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform	sampler2D rgb_img[8];

void main() {
  for (int iters = 0; iters < 8; iters++) {
    vec4 rgb_color = texture(rgb_img[iters], TexCoord);
    float gray_color = (rgb_color[0] + rgb_color[1] + rgb_color[2])/3.0;
    FragColor[iters] = vec4(vec3(gray_color), 1.0);
  }
}
