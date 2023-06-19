vec2 opRevolution(in vec3 p, float o) {
  return vec2(length(p.xz) - o, p.y);
}
