float calcSoftshadow(in vec3 ro, in vec3 rd, in float mint, in float tmax) {
  float tp = (0.8 - ro.y) / rd.y;
  if(tp > 0.0)
    tmax = min(tmax, tp);

  float res = 1.0;
  float t = mint;
  for(int i = 0; i < 24; i++) {
    float h = map(ro + rd * t).x;
    float s = clamp(8.0 * h / t, 0.0, 1.0);
    res = min(res, s);
    t += clamp(h, 0.01, 0.2);
    if(res < 0.004 || t > tmax)
      break;
  }
  res = clamp(res, 0.0, 1.0);
  return res * res * (3.0 - 2.0 * res);
}

vec3 calcNormal(in vec3 pos) {
  // inspired by tdhooper and klems - a way to prevent the compiler from inlining map() 4 times
  vec3 n = vec3(0.0);
  for(int i = 0; i < 4; i++) {
    vec3 e = 0.5773 * (2.0 * vec3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
    n += e * map(pos + 0.0005 * e).x;
  }
  return normalize(n);
}

float calcAO(in vec3 pos, in vec3 nor) {
  float occ = 0.0;
  float sca = 1.0;
  for(int i = 0; i < 5; i++) {
    float h = 0.01 + 0.12 * float(i) / 4.0;
    float d = map(pos + h * nor).x;
    occ += (h - d) * sca;
    sca *= 0.95;
    if(occ > 0.35)
      break;
  }
  return clamp(1.0 - 3.0 * occ, 0.0, 1.0) * (0.5 + 0.5 * nor.y);
}
