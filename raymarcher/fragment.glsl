#version 300 es
precision highp float;
uniform float iTime;
uniform float iTimeDelta;
uniform vec3 iResolution;

out vec4 fragColor;

##SHADER##

void main(void) {
  mainImage(fragColor, gl_FragCoord.xy);
}
