float opDisplace(in float displaced, in vec3 p, in float k) {
  return displaced + sin(5.0 * p.x) * sin(5.0 * p.y) * sin(5.0 * p.z) * k;
}
