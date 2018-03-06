#version 330

out vec4 output;
in float Depth;

void main() {
  vec4 color;
  if(Depth > 20 && Depth < 360) {
    color = vec4((Depth - 20.0)/(360.0));
  } else if (Depth <= 20) {
    color = vec4(0);
  } else {
    color = vec4(255);
  }
  output = (color);
}
