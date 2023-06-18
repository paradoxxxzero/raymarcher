#include raymarch_3d_primitives
#include raymarch_transformations

const float PI = 3.1415926535897932384626433832795;

vec4 map(in vec3 p) {
  const vec3 donutColor = vec3(0.31, 0.16, 0.97);
  const vec3 boxColor = vec3(1.0, 0.32, 0.32);
  const vec3 octahedronColor = vec3(0.44, 1.0, 0.43);

  vec3 dp = opRotateX(p, PI / 2.);
  dp = opRotateZ(dp, PI / 6.);
  dp = opRotateY(dp, .3 * iTime);
  // dp = opTwist(dp, .4 * cos(2. * iTime));
  dp = opRotateX(dp, .3 * iTime);
  dp = opRepeatLimited(dp, 1.25, vec3(1.5));
  // dp = opRepeat(dp, vec3(1.6));
  float donut = sdTorus(dp, vec2(.2, .1));
  donut = opDisplace(donut, p, .005 * (1. + cos(5. * iTime)));

  vec3 bp = opRotateX(p, .7 * iTime);
  bp = opTranslate(bp, vec3(.5, .5, .5));
  bp = opRepeatLimited(bp, .9, vec3(1.5));
  float box = sdBox(bp, vec3(.07));

  vec3 cp = opRotateZ(p, .5 * iTime);
  cp = opTranslate(cp, vec3(-.5, -1., 1.));
  cp = opRepeatLimited(cp, 1.1, vec3(1.5));
  float octahedron = sdOctahedron(cp, .1);
  octahedron = opRound(octahedron, .04);

  vec4 u = opSmoothUnion(vec4(donut, donutColor), vec4(box, boxColor), .5);
  u = opSmoothUnion(u, vec4(octahedron, octahedronColor), .5);
  return u;
}

#include raymarch_rendering

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
  const float minLen = 0.01;
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

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

  vec3 camera = vec3(0.0, 0.0, -5.0);
  vec3 ro = camera;
  vec3 rd = vec3(uv, 1.0);

  vec3 color = rayMarch(ro, rd); // This use the map function defined above
  fragColor = vec4(color, 1.0);
}
