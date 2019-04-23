#version 330

out vec4 FragColor[8];

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform	sampler2D gray_img[8];

int indexMatrix4x4[16] = int[](0, 8, 2, 10,
			  12, 4, 14, 6,
			  3, 11, 1, 9,
			  15, 7, 13, 5);

float indexValue() {
  int x = int(mod(gl_FragCoord.x, 4));
  int y = int(mod(gl_FragCoord.y, 4));
  return indexMatrix4x4[x + y*4]/16.0;
}

float dither(float color) {
  float closestColor = (color < 0.5)?0:1;
  float secondClosestColor = 1.0 - closestColor;
  float d = indexValue();
  float distance = abs(closestColor - color);
  return (distance <= d)?closestColor:secondClosestColor;
}


void main() {
  for (int iters = 0; iters < 8; iters++) {
    vec4 gray_color = texture(gray_img[iters], TexCoord);
    FragColor[iters] = vec4(vec3(dither(gray_color[0])), 1.0);
  }
}
