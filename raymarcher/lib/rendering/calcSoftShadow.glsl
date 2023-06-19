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
