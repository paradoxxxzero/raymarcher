vec3 calcNormal(in vec3 pos) {
  vec3 n = vec3(0.0);
  for(int i = 0; i < 4; i++) {
    vec3 e = 0.5773 * (2.0 * vec3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
    n += e * map(pos + 0.0005 * e).x;
  }
  return normalize(n);
}
