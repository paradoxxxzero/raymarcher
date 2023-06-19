float sdBlobbyCross(in vec2 pos, float he) {
  pos = abs(pos);
  pos = vec2(abs(pos.x - pos.y), 1.0 - pos.x - pos.y) / sqrt(2.0);

  float p = (he - pos.y - 0.25 / he) / (6.0 * he);
  float q = pos.x / (he * he * 16.0);
  float h = q * q - p * p * p;

  float x;
  if(h > 0.0) {
    float r = sqrt(h);
    x = pow(q + r, 1.0 / 3.0) - pow(abs(q - r), 1.0 / 3.0) * sign(r - q);
  } else {
    float r = sqrt(p);
    x = 2.0 * r * cos(acos(q / (p * r)) / 3.0);
  }
  x = min(x, sqrt(2.0) / 2.0);

  vec2 z = vec2(x, he * (1.0 - 2.0 * x * x)) - pos;
  return length(z) * sign(z.y);
}
