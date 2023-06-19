vec3 opElongateEnter(in vec3 p, in vec3 h) {
  vec3 q = abs(p) - h;
  return max(q, 0.0);
}
