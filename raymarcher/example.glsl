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
vec4 opSmoothUnion(vec4 d1, vec4 d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2.x - d1.x) / k, 0.0, 1.0);
  return vec4(mix(d2.x, d1.x, h) - k * h * (1.0 - h), mix(d2.yzw, d1.yzw, h));
}

vec3 opBend(in vec3 p, float k) {
  return opRotateZ(p, k * p.x);
}

float sdBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}
float sdPlane(vec3 point) {
  return point.y;
}

float sinc(in float x) {
  return sin(x) / x;
}

vec4 map(in vec3 p) {
  const vec3 planeColor = vec3(.2, .4, .9);
  const vec3 boxColor = vec3(1.0, 0.32, 0.32);

  float plane = p.y + .2 / (pow(length(p), 2.) + 1.) * sin(10. * length(p) - 2. * iTime);
  vec3 bp = p;

  bp = opRotateX(bp, .7 * iTime);
  bp = opBend(bp, sin(iTime * 2.));
  bp = opTranslate(bp, vec3(0., 0., .5 - .1 * sin(iTime)));

  float box = sdBox(bp, vec3(.4, .2, .6));

  vec4 u = opSmoothUnion(vec4(plane, planeColor), vec4(box, boxColor), .5);
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

vec3 shade(in vec3 color, in vec3 p, in bool inside) {
  vec3 col = vec3(0.0);

  if(inside) {
    vec3 normal = calcNormal(p);
    float ao = calcAO(p, normal);

    vec3 lamp = vec3(2., -1., 3.);
    vec3 light = normalize(p - lamp);

    float ambient = .1;
    float diffuse = clamp(dot(normal, light), 0., 1.);
    float specular = clamp(pow(dot(normal, normalize(light + p)), 100.0), 0., 1.);
    col = color * (ambient + diffuse + specular) * ao;

    col = sqrt(col);
  }
  return col;
}

vec3 rayMarch(in vec3 ro, in vec3 rd) {
  float len = 0.;
  const float minLen = 0.;
  const float maxLen = 15.;
  vec3 p;
  vec4 mapped;

  for(int i = 0; i < 50; i++) {
    p = ro + len * rd;

    mapped = map(p);

    if(abs(mapped.x) < minLen || len > maxLen) {
      break;
    }

    len += mapped.x;
  }
  return shade(mapped.yzw, p, len < maxLen);
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
  vec3 cw = normalize(ta - ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize(cross(cw, cp));
  vec3 cv = (cross(cu, cw));
  return mat3(cu, cv, cw);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 mo = iMouse.xy / iResolution.xy;
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
  vec3 ta = vec3(0.);

  float an = 0.7 * iTime + 4.0 * mo.x;
  vec3 ro = ta + vec3(7. * cos(an), 2. - 4. * (mo.y - .5), 7. * sin(an));
  mat3 ca = setCamera(ro, ta, 0.0);
  const float focal = 2.5;
  vec3 rd = ca * normalize(vec3(uv, focal));

  vec3 color = rayMarch(ro, rd);
  fragColor = vec4(color, 1.0);
}
