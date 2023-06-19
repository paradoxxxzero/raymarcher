vec3 opRepeatLimited(in vec3 p, in float c, in vec3 l) {
  return p - c * clamp(round(p / c), -l, l);
}
