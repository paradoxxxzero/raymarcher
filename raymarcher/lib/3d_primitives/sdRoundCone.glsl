float sdRoundCone(vec3 p, vec3 a, vec3 b, float r1, float r2) {
    // sampling independent computations (only depend on shape)
  vec3 ba = b - a;
  float l2 = dot(ba, ba);
  float rr = r1 - r2;
  float a2 = l2 - rr * rr;
  float il2 = 1.0 / l2;

    // sampling dependant computations
  vec3 pa = p - a;
  float y = dot(pa, ba);
  float z = y - l2;
  float x2 = dot(pa * l2 - ba * y);
  float y2 = y * y * l2;
  float z2 = z * z * l2;

    // single square root!
  float k = sign(rr) * rr * rr * x2;
  if(sign(z) * a2 * z2 > k)
    return sqrt(x2 + z2) * il2 - r2;
  if(sign(y) * a2 * y2 < k)
    return sqrt(x2 + y2) * il2 - r1;
  return (sqrt(x2 * a2 * il2) + y * rr) * il2 - r1;
}
