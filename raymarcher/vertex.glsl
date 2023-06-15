#version 300 es
precision highp float;

const vec2 vertices[3] = vec2[3](vec2(-1, -1), vec2(3, -1), vec2(-1, 3));

out vec2 uv;

void main() {
  gl_Position = vec4(vertices[gl_VertexID], 0., 1.);
}
