vec3 opRotateX(in vec3 p, in float theta) {
  float c = cos(theta);
  float s = sin(theta);
  p.yz *= mat2(c, s, -s, c);
  return p;
}
vec3 opRotateY(in vec3 p, in float theta) {
  float c = cos(theta);
  float s = sin(theta);

  p.xz *= mat2(c, s, -s, c);
  return p;
}
vec3 opRotateZ(in vec3 p, in float theta) {
  float c = cos(theta);
  float s = sin(theta);
  p.xy *= mat2(c, -s, s, c);
  return p;
}

vec3 opTranslate(in vec3 p, in vec3 t) {
  return p - t;
}

vec3 opScaleEnter(in vec3 p, in float s) {
  return p / s;
}

float opScaleExit(in float p, in float s) {
  return p * s;
}
vec3 opSymX(in vec3 p) {
  p.x = abs(p.x);
  return p;
}

vec3 opRepeat(in vec3 p, in vec3 c) {
  return mod(p + 0.5 * c, c) - 0.5 * c;
}

vec3 opRepeatLimited(in vec3 p, in float c, in vec3 l) {
  return p - c * clamp(round(p / c), -l, l);
}

float opDisplace(in float displaced, in vec3 p, in float k) {
  return displaced + sin(5.0 * p.x) * sin(5.0 * p.y) * sin(5.0 * p.z) * k;
}

vec3 opTwist(in vec3 p, float k) {
  return opRotateY(p, k * p.y);
}

vec3 opBend(in vec3 p, float k) {
  return opRotateZ(p, k * p.x);
}

vec4 opUnion(vec4 d1, vec4 d2) {
  return d1.x < d2.x ? d1 : d2;
}

vec4 opIntersection(vec4 d1, vec4 d2) {
  return d1.x < d2.x ? d2 : d1;
}
vec4 opSubtraction(vec4 d1, vec4 d2) {
  d1.x *= -1.;
  return opIntersection(d1, d2);
}

vec4 opSmoothUnion(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2.x - d1.x) / k, 0.0, 1.0);
  return vec4(mix(d2.x, d1.x, h) - k * h * (1.0 - h), mix(d2.yzw, d1.yzw, h));
}

vec4 opSmoothSubtraction(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 - 0.5 * (d2.x + d1.x) / k, 0.0, 1.0);
  return vec4(mix(d2.x, -d1.x, h) + k * h * (1.0 - h), mix(d2.yzw, d1.yzw, h));
}

vec4 opSmoothIntersection(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 - 0.5 * (d2.x - d1.x) / k, 0.0, 1.0);
  return vec4(mix(d2.x, d1.x, h) + k * h * (1.0 - h), mix(d2.yzw, d1.yzw, h));
}

vec3 opElongate(in vec3 p, in vec3 h) {
  return p - clamp(p, -h, h);
}

vec3 opElongateEnter(in vec3 p, in vec3 h) {
  vec3 q = abs(p) - h;
  return max(q, 0.0);
}
float opElongateExit(in float d, in vec3 p, in float h) {
  vec3 q = abs(p) - h;
  return d + min(max(q.x, max(q.y, q.z)), 0.0);
}

float opRound(in float d, in float rad) {
  return d - rad;
}

float opOnion(in float d, in float thickness) {
  return abs(d) - thickness;
}

float opExtrusion(in vec3 p, in float dxy, in float h) {
  // dxy = sdf2dShape(p.xy)
  vec2 w = vec2(dxy, abs(p.z) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}

vec2 opRevolution(in vec3 p, float o) {
  return vec2(length(p.xz) - o, p.y);
}
