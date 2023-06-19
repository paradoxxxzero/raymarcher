float sdParabola(in vec2 pos, in float wi, in float he) {
  pos.x = abs(pos.x);
  float ik = wi * wi / he;
  float p = ik * (he - pos.y - 0.5 * ik) / 3.0;
  float q = pos.x * ik * ik * 0.25;
  float h = q * q - p * p * p;
  float r = sqrt(abs(h));
  float x = (h > 0.0) ? pow(q + r, 1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q) : 2.0 * cos(atan(r / q) / 3.0) * sqrt(p);
  x = min(x, wi);
  return length(pos - vec2(x, he - x * x / ik)) *
    sign(ik * (pos.y - he) + pos.x * pos.x);
}
