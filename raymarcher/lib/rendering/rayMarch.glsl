vec3 rayMarch(in vec3 ro, in vec3 rd) {
  float len = 0.;
  const float minLen = 0.0001;
  const float maxLen = 10.;
  vec3 p;
  vec4 mapped;

  for(int i = 0; i < 64; i++) {
    p = ro + len * rd;

    mapped = map(p);

    if(mapped.x < minLen || len > maxLen) {
      break;
    }

    len += mapped.x;
  }
  return shade(mapped.yzw, p, len < maxLen);
}
