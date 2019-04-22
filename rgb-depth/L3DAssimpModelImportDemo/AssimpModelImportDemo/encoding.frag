#version 330

out vec4 FragColor;

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform	sampler2D binary_img[8];

void main() {
  float color = 0.0;
  for (int iters = 0; iters < 8; iters++) {
    vec4 binary_color = texture(binary_img[iters], TexCoord);
    if(binary_color[0] == 1.0) {
      //color = color + 1.0/(2.0*pow(2.0, (iters)));
      color = color + (128.0/255.0)/(pow(2.0,iters));
    }
  }
  FragColor = vec4(vec3(color), 1.0);
}
