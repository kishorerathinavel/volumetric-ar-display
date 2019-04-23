#version 330

out vec4 FragColor[2];

in vec2 TexCoord;
in vec4 gl_FragCoord;

uniform	sampler2D rgb_img;
uniform	sampler2D depth_map;
uniform float zNear;
uniform float zFar;

void main() {
  /* The real depth value was mapped to the range [0,1] in a previous shader. 
     The below code does the reverse mapping from [0,1] to the real depth value.
     Code taken from: http://web.archive.org/web/20130416194336/http://olivers.posterous.com/linear-depth-in-glsl-for-real
     Backups of code in Google Drive. Filename: Real Depth in OpenGL_GLSL
   */
  vec4 vec4_z_b = texture(depth_map, TexCoord);
  float z_b = vec4_z_b[0];
  float z_n = 2.0 * z_b - 1.0;
  float z_e = 2.0 * zNear * zFar / (zFar + zNear - z_n *(zFar - zNear));
  float normalized_linear_depth = (z_e - zNear)/zFar;

  vec4 rgb_color = texture(rgb_img, TexCoord);

  FragColor[0] = vec4(vec3(0.0), 1.0);
  FragColor[1] = vec4(vec3(0.0), 1.0);

  if(normalized_linear_depth < 0.5) {
    FragColor[0] = rgb_color;
  } else {
    FragColor[1] = rgb_color;
  }
}
