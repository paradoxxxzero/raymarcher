// This is a collection of existing signed distance functions for various shapes
// Found at:
//   - https://iquilezles.org/articles/distfunctions/
//   - https://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/

float dot2(in vec2 v) {
  return dot(v, v);
}
float dot2(in vec3 v) {
  return dot(v, v);
}
float ndot(in vec2 a, in vec2 b) {
  return a.x * b.x - a.y * b.y;
}

float sdPlane(vec3 point) {
  return point.y;
}

float sdSphere(vec3 p, float s) {
  return length(p) - s;
}

float sdBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float sdRoundBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdBoxFrame(vec3 p, vec3 b, float e) {
  p = abs(p) - b;
  vec3 q = abs(p + e) - e;

  return min(min(length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0), length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)), length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}

float sdEllipsoid(in vec3 p, in vec3 r) {
  float k0 = length(p / r);
  float k1 = length(p / (r * r));
  return k0 * (k0 - 1.0) / k1;
}

float sdTorus(vec3 p, vec2 t) {
  return length(vec2(length(p.xz) - t.x, p.y)) - t.y;
}

float sdCappedTorus(in vec3 p, in vec2 sc, in float ra, in float rb) {
  p.x = abs(p.x);
  float k = (sc.y * p.x > sc.x * p.y) ? dot(p.xy, sc) : length(p.xy);
  return sqrt(dot(p, p) + ra * ra - 2.0 * ra * k) - rb;
}

float sdHexPrism(vec3 p, vec2 h) {
  vec3 q = abs(p);

  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0 * min(dot(k.xy, p.xy), 0.0) * k.xy;
  vec2 d = vec2(length(p.xy - vec2(clamp(p.x, -k.z * h.x, k.z * h.x), h.x)) * sign(p.y - h.x), p.z - h.y);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdOctogonPrism(in vec3 p, in float r, float h) {
  const vec3 k = vec3(-0.9238795325,   // sqrt(2+sqrt(2))/2 
  0.3826834323,   // sqrt(2-sqrt(2))/2
  0.4142135623); // sqrt(2)-1 
  // reflections
  p = abs(p);
  p.xy -= 2.0 * min(dot(vec2(k.x, k.y), p.xy), 0.0) * vec2(k.x, k.y);
  p.xy -= 2.0 * min(dot(vec2(-k.x, k.y), p.xy), 0.0) * vec2(-k.x, k.y);
  // polygon side
  p.xy -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
  vec2 d = vec2(length(p.xy) * sign(p.y), p.z - h);
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p - a, ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h) - r;
}

float sdRoundCone(in vec3 p, in float r1, float r2, float h) {
  vec2 q = vec2(length(p.xz), p.y);

  float b = (r1 - r2) / h;
  float a = sqrt(1.0 - b * b);
  float k = dot(q, vec2(-b, a));

  if(k < 0.0)
    return length(q) - r1;
  if(k > a * h)
    return length(q - vec2(0.0, h)) - r2;

  return dot(q, vec2(a, b)) - r1;
}

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
  float x2 = dot2(pa * l2 - ba * y);
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

float sdTriPrism(vec3 p, vec2 h) {
  const float k = sqrt(3.0);
  h.x *= 0.5 * k;
  p.xy /= h.x;
  p.x = abs(p.x) - 1.0;
  p.y = p.y + 1.0 / k;
  if(p.x + k * p.y > 0.0)
    p.xy = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
  p.x -= clamp(p.x, -2.0, 0.0);
  float d1 = length(p.xy) * sign(-p.y) * h.x;
  float d2 = abs(p.z) - h.y;
  return length(max(vec2(d1, d2), 0.0)) + min(max(d1, d2), 0.);
}

// vertical
float sdCylinder(vec3 p, vec2 h) {
  vec2 d = abs(vec2(length(p.xz), p.y)) - h;
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// arbitrary orientation
float sdCylinder(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p - a;
  vec3 ba = b - a;
  float baba = dot(ba, ba);
  float paba = dot(pa, ba);

  float x = length(pa * baba - ba * paba) - r * baba;
  float y = abs(paba - baba * 0.5) - baba * 0.5;
  float x2 = x * x;
  float y2 = y * y * baba;
  float d = (max(x, y) < 0.0) ? -min(x2, y2) : (((x > 0.0) ? x2 : 0.0) + ((y > 0.0) ? y2 : 0.0));
  return sign(d) * sqrt(abs(d)) / baba;
}

// vertical
float sdCone(in vec3 p, in vec2 c, float h) {
  vec2 q = h * vec2(c.x, -c.y) / c.y;
  vec2 w = vec2(length(p.xz), p.y);

  vec2 a = w - q * clamp(dot(w, q) / dot(q, q), 0.0, 1.0);
  vec2 b = w - q * vec2(clamp(w.x / q.x, 0.0, 1.0), 1.0);
  float k = sign(q.y);
  float d = min(dot(a, a), dot(b, b));
  float s = max(k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
  return sqrt(d) * sign(s);
}

float sdCappedCone(in vec3 p, in float h, in float r1, in float r2) {
  vec2 q = vec2(length(p.xz), p.y);

  vec2 k1 = vec2(r2, h);
  vec2 k2 = vec2(r2 - r1, 2.0 * h);
  vec2 ca = vec2(q.x - min(q.x, (q.y < 0.0) ? r1 : r2), abs(q.y) - h);
  vec2 cb = q - k1 + k2 * clamp(dot(k1 - q, k2) / dot2(k2), 0.0, 1.0);
  float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
  return s * sqrt(min(dot2(ca), dot2(cb)));
}

float sdCappedCone(vec3 p, vec3 a, vec3 b, float ra, float rb) {
  float rba = rb - ra;
  float baba = dot(b - a, b - a);
  float papa = dot(p - a, p - a);
  float paba = dot(p - a, b - a) / baba;

  float x = sqrt(papa - paba * paba * baba);

  float cax = max(0.0, x - ((paba < 0.5) ? ra : rb));
  float cay = abs(paba - 0.5) - 0.5;

  float k = rba * rba + baba;
  float f = clamp((rba * (x - ra) + paba * baba) / k, 0.0, 1.0);

  float cbx = x - ra - f * rba;
  float cby = paba - f;

  float s = (cbx < 0.0 && cay < 0.0) ? -1.0 : 1.0;

  return s * sqrt(min(cax * cax + cay * cay * baba, cbx * cbx + cby * cby * baba));
}

// c is the sin/cos of the desired cone angle
float sdSolidAngle(vec3 pos, vec2 c, float ra) {
  vec2 p = vec2(length(pos.xz), pos.y);
  float l = length(p) - ra;
  float m = length(p - c * clamp(dot(p, c), 0.0, ra));
  return max(l, m * sign(c.y * p.x - c.x * p.y));
}

float sdOctahedron(vec3 p, float s) {
  p = abs(p);
  float m = p.x + p.y + p.z - s;

    // exact distance
    #if 0
  vec3 o = min(3.0 * p - m, 0.0);
  o = max(6.0 * p - m * 2.0 - o * 3.0 + (o.x + o.y + o.z), 0.0);
  return length(p - s * o / (o.x + o.y + o.z));
    #endif

    // exact distance
    #if 1
  vec3 q;
  if(3.0 * p.x < m)
    q = p.xyz;
  else if(3.0 * p.y < m)
    q = p.yzx;
  else if(3.0 * p.z < m)
    q = p.zxy;
  else
    return m * 0.57735027;
  float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
  return length(vec3(q.x, q.y - s + k, q.z - k)); 
    #endif

    // bound, not exact
    #if 0
  return m * 0.57735027;
    #endif
}

float sdPyramid(in vec3 p, in float h) {
  float m2 = h * h + 0.25;

    // symmetry
  p.xz = abs(p.xz);
  p.xz = (p.z > p.x) ? p.zx : p.xz;
  p.xz -= 0.5;

    // project into face plane (2D)
  vec3 q = vec3(p.z, h * p.y - 0.5 * p.x, h * p.x + 0.5 * p.y);

  float s = max(-q.x, 0.0);
  float t = clamp((q.y - 0.5 * p.z) / (m2 + 0.25), 0.0, 1.0);

  float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
  float b = m2 * (q.x + 0.5 * t) * (q.x + 0.5 * t) + (q.y - m2 * t) * (q.y - m2 * t);

  float d2 = min(q.y, -q.x * m2 - q.y * 0.5) > 0.0 ? 0.0 : min(a, b);

    // recover 3D and scale, and add sign
  return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
  ;
}

// la,lb=semi axis, h=height, ra=corner
float sdRhombus(vec3 p, float la, float lb, float h, float ra) {
  p = abs(p);
  vec2 b = vec2(la, lb);
  float f = clamp((ndot(b, b - 2.0 * p.xz)) / dot(b, b), -1.0, 1.0);
  vec2 q = vec2(length(p.xz - 0.5 * b * vec2(1.0 - f, 1.0 + f)) * sign(p.x * b.y + p.z * b.x - b.x * b.y) - ra, p.y - h);
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0));
}

float sdHorseshoe(in vec3 p, in vec2 c, in float r, in float le, vec2 w) {
  p.x = abs(p.x);
  float l = length(p.xy);
  p.xy = mat2(-c.x, c.y, c.y, c.x) * p.xy;
  p.xy = vec2((p.y > 0.0 || p.x > 0.0) ? p.x : l * sign(-c.x), (p.x > 0.0) ? p.y : l);
  p.xy = vec2(p.x, abs(p.y - r)) - vec2(le, 0.0);

  vec2 q = vec2(length(max(p.xy, 0.0)) + min(0.0, max(p.x, p.y)), p.z);
  vec2 d = abs(q) - w;
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdU(in vec3 p, in float r, in float le, vec2 w) {
  p.x = (p.y > 0.0) ? abs(p.x) : length(p.xy);
  p.x = abs(p.x - r);
  p.y = p.y - le;
  float k = max(p.x, p.y);
  vec2 q = vec2((k < 0.0) ? -k : length(max(p.xy, 0.0)), abs(p.z)) - w;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

//------------------------------------------------------------------

vec2 opU(vec2 d1, vec2 d2) {
  return (d1.x < d2.x) ? d1 : d2;
}

//------------------------------------------------------------------

//------------------------------------------------------------------

// https://iquilezles.org/articles/boxfunctions
vec2 iBox(in vec3 ro, in vec3 rd, in vec3 rad) {
  vec3 m = 1.0 / rd;
  vec3 n = m * ro;
  vec3 k = abs(m) * rad;
  vec3 t1 = -n - k;
  vec3 t2 = -n + k;
  return vec2(max(max(t1.x, t1.y), t1.z), min(min(t2.x, t2.y), t2.z));
}

// https://iquilezles.org/articles/checkerfiltering
float checkersGradBox(in vec2 p, in vec2 dpdx, in vec2 dpdy) {
    // filter kernel
  vec2 w = abs(dpdx) + abs(dpdy) + 0.001;
    // analytical integral (box filter)
  vec2 i = 2.0 * (abs(fract((p - 0.5 * w) * 0.5) - 0.5) - abs(fract((p + 0.5 * w) * 0.5) - 0.5)) / w;
    // xor pattern
  return 0.5 - 0.5 * i.x * i.y;
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
  vec3 cw = normalize(ta - ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize(cross(cw, cp));
  vec3 cv = (cross(cu, cw));
  return mat3(cu, cv, cw);
}
