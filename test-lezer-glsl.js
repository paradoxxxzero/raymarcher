import { parser } from './lezer-glsl/glsl-parser.js'
import { fileTests } from '@lezer/generator/test'

// let tree = parser.parse(`
// // COMMMENT

// void mainImage(out vec4 fragColor, in vec2 fragCoord) {
//   const float f = 4.;
//   fragColor = vec4(vec3(f), 0.);
// }
// `)
let tree = parser.parse(`
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  const float f = 3. * 2. + 4. == 0.? 8. : 3.; 
  fragColor.xxz = vec4(vec3(f), 0.);
}
`)
console.log(tree.toString())
