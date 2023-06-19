const float PI = 3.1415926535897932384626433832795;

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

vec3 opRepeat(in vec3 p, in vec3 c) {
  return mod(p + 0.5 * c, c) - 0.5 * c;
}

float opRound(in float d, in float rad) {
  return d - rad;
}

vec4 opSmoothUnion(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2.x - d1.x) / k, 0.0, 1.0);
  return vec4(mix(d2.x, d1.x, h) - k * h * (1.0 - h), mix(d2.yzw, d1.yzw, h));
}

float sdTorus(vec3 p, vec2 t) {
  return length(vec2(length(p.xz) - t.x, p.y)) - t.y;
}

float sdBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
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

vec4 map(in vec3 p) {
  const vec3 donutColor = vec3(0.31, 0.16, 0.97);
  const vec3 boxColor = vec3(1.0, 0.32, 0.32);
  const vec3 octahedronColor = vec3(0.44, 1.0, 0.43);

  vec3 dp = opRotateX(p, PI / 2.);
  // dp = opRotateZ(dp, PI / 6.);
  // dp = opRotateY(dp, .3 * iTime);
  // dp = opTwist(dp, .4 * cos(2. * iTime));
  // dp = opRotateX(dp, .3 * iTime);
  dp = opRepeat(dp, vec3(1.25));
  // dp = opRepeat(dp, vec3(1.6));
  float donut = sdTorus(dp, vec2(.03, .007));
  // donut = opDisplace(donut, p, .005 * (1. + cos(5. * iTime)));

  vec3 bp = opRotateX(p, .7 * iTime);
  bp = opTranslate(bp, vec3(.5, .5, .5));
  bp = opRepeat(bp, vec3(.9));
  float box = sdBox(bp, vec3(.01));

  vec3 cp = opRotateZ(p, .5 * iTime);
  cp = opTranslate(cp, vec3(-.5, -1., 1.));
  cp = opRepeat(cp, vec3(1.1));
  float octahedron = sdOctahedron(cp, .03);
  octahedron = opRound(octahedron, .004);

  vec4 u = opSmoothUnion(vec4(donut, donutColor), vec4(box, boxColor), .01);
  u = opSmoothUnion(u, vec4(octahedron, octahedronColor), .01);
  return u;
}

vec3 calcNormal(in vec3 pos) {
  vec3 n = vec3(0.0);
  for(int i = 0; i < 4; i++) {
    vec3 e = 0.5773 * (2.0 * vec3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
    n += e * map(pos + 0.0005 * e).x;
  }
  return normalize(n);
}

vec3 shade(in vec3 color, in vec3 p, in bool inside) {
  vec3 col = vec3(0.0);

  if(inside) {
    vec3 normal = calcNormal(p);
    // vec3 ao = calcAO(p, normal);

    vec3 lamp = vec3(2., -1., 3.);
    lamp = opRotateY(lamp, iTime * 2.);
    vec3 light = normalize(p - lamp);

    float ambient = .1;
    float diffuse = clamp(dot(normal, light), 0., 1.);
    float specular = clamp(pow(dot(normal, normalize(light + p)), 100.0), 0., 1.);
    col = color * (ambient + diffuse + specular);

    col = sqrt(col);
  }
  return col;
}

vec3 rayMarch(in vec3 ro, in vec3 rd) {
  float len = 0.;
  const float minLen = 0.;
  const float maxLen = 10.;
  vec3 p;
  vec4 mapped;

  for(int i = 0; i < 128; i++) {
    p = ro + len * rd;

    mapped = map(p);

    if(mapped.x < minLen || len > maxLen) {
      break;
    }

    len += mapped.x;
  }
  return shade(mapped.yzw, p, len < maxLen);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

  float an = 0.7 * iTime;
  vec3 ro = vec3(1.0 * cos(an), 0.2, -5.0 + sin(an));

  vec3 ta = vec3(0.0, 0.0, 0.0);
  vec3 ww = normalize(ta - ro);
  vec3 uu = normalize(cross(ww, vec3(0.0, 1.0, 0.0)));
  vec3 vv = (cross(uu, ww));

  vec3 rd = normalize(uv.x * uu + uv.y * vv + 5. * ww);

  vec3 color = rayMarch(ro, rd); // This use the map function defined above
  fragColor = vec4(color, 1.0);
}
