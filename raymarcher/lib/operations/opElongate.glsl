vec3 opElongate(in vec3 p, in vec3 h) {
  return p - clamp(p, -h, h);
}
