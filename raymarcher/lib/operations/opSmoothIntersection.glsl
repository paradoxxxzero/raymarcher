vec4 opSmoothIntersection(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 - 0.5 * (d2.x - d1.x) / k, 0.0, 1.0);
  return vec4(mix(d2.x, d1.x, h) + k * h * (1.0 - h), mix(d2.yzw, d1.yzw, h));
}
