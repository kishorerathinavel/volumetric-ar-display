#version 330

out vec4 output;
in float Depth;

void main() {
  vec4 color;
  color = vec4(Depth/10.0);
  output = (color);
}
