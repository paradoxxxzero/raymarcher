vec3 opRepeat(in vec3 p, in vec3 c) {
  return mod(p + 0.5 * c, c) - 0.5 * c;
}
