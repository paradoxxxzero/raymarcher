import vertexSource from './vertex.glsl'
import fragmentSource from './fragment.glsl'
import example from './example.glsl'
import { getSourceFromUrl, setUrlFromSource } from './browser'
import { setEditSource } from './edit'

let gl = null
let program = null
let vertexShader = null
let fragmentShader = null

const uniforms = {}

let shader = getSourceFromUrl() || example

export const getShader = () => shader
export const setShader = newShader => {
  const compilationError = compileShader(
    plugFragment(fragmentSource, newShader),
    fragmentShader
  )
  if (compilationError) {
    return compilationError
  }
  const linkError = linkProgram()
  if (linkError) {
    return linkError
  }
  setUrlFromSource(newShader)
  shader = newShader
  frame = 0
  t0 = performance.now() / 1000
  sizeGL()
}

window.addEventListener('popstate', () => {
  const shader = getSourceFromUrl()
  if (shader) {
    setEditSource(shader)
    setShader(shader)
  }
})

const compileShader = (shaderSource, shader) => {
  gl.shaderSource(shader, shaderSource)
  gl.compileShader(shader)
  const success = gl.getShaderParameter(shader, gl.COMPILE_STATUS)
  if (!success) {
    const error = gl.getShaderInfoLog(shader)
    console.error(`An error occurred compiling the shaders: ${error}`)
    return error
  }
}

const linkProgram = () => {
  gl.linkProgram(program)

  const success = gl.getProgramParameter(program, gl.LINK_STATUS)
  if (!success) {
    const error = gl.getProgramInfoLog(program)
    console.error(`Unable to initialize the shader program: ${error}`)
    return error
  }

  uniforms.iTime = gl.getUniformLocation(program, 'iTime')
  uniforms.iTimeDelta = gl.getUniformLocation(program, 'iTimeDelta')
  uniforms.iFrame = gl.getUniformLocation(program, 'iFrame')
  uniforms.iResolution = gl.getUniformLocation(program, 'iResolution')
  uniforms.iMouse = gl.getUniformLocation(program, 'iMouse')
}

const plugFragment = (fragmentShader, plug) =>
  fragmentShader.replace('##SHADER##', plug)

export const initGL = canvas => {
  gl = canvas.getContext('webgl2')

  vertexShader = gl.createShader(gl.VERTEX_SHADER)
  fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)

  compileShader(vertexSource, vertexShader)
  compileShader(plugFragment(fragmentSource, shader), fragmentShader)

  program = gl.createProgram()
  gl.attachShader(program, vertexShader)
  gl.attachShader(program, fragmentShader)

  linkProgram()

  gl.useProgram(program)

  gl.drawArrays(gl.TRIANGLES, 0, 3)
  sizeGL()

  const playpause = document.getElementById('playpause')
  playpause.addEventListener('click', () => {
    if (pause !== null) {
      playpause.innerHTML = '⏸️'
      pauseDt += performance.now() / 1000 - pause
      pause = null
      render()
    } else {
      playpause.innerHTML = '▶️'
      pause = performance.now() / 1000
    }
  })
}

export const sizeGL = () => {
  if (!gl) {
    return
  }
  gl.canvas.width = window.innerWidth
  gl.canvas.height = window.innerHeight
  gl.canvas.style.width = window.innerWidth + 'px'
  gl.canvas.style.height = window.innerHeight + 'px'
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height)
  gl.uniform3fv(uniforms.iResolution, [
    gl.canvas.width,
    gl.canvas.height,
    window.devicePixelRatio,
  ])

  gl.drawArrays(gl.TRIANGLES, 0, 3)
}

let sma = 0
const k = 50
const dts = new Array(k).fill(0)

let t0 = performance.now() / 1000
let pauseDt = 0
let raf = null
let pause = null
let frame = 0
let mouse = [0, 0, 0, 0]

export const render = () => {
  const t = performance.now() / 1000 - pauseDt
  dts.push(t - t0)
  t0 = t
  sma += (dts[dts.length - 1] - dts.shift()) / dts.length
  gl.uniform1f(uniforms.iTime, t)
  gl.uniform1f(uniforms.iFrame, frame++)
  gl.uniform1f(uniforms.iTimeDelta, dts[dts.length - 1])
  gl.uniform4fv(uniforms.iMouse, mouse)

  gl.drawArrays(gl.TRIANGLES, 0, 3)
  if (mouse[3] > 0) {
    mouse[3] *= -1
  }
  if (pause === null) {
    raf = requestAnimationFrame(render)
  }
}

setInterval(() => {
  if (frame > k) {
    document.getElementById('fps').innerHTML = `${(1 / sma).toFixed(1)}`
  }
}, 100)

const onMove = e => {
  mouse[0] = e.clientX
  mouse[1] = window.innerHeight - e.clientY
}

const onDown = e => {
  if (e.button !== 0 || e.target.tagName !== 'CANVAS') {
    return
  }
  mouse[0] = e.clientX
  mouse[1] = window.innerHeight - e.clientY
  mouse[2] = e.clientX
  mouse[3] = window.innerHeight - e.clientY

  const onUp = e => {
    mouse[2] *= -1

    window.removeEventListener('pointermove', onMove)
  }
  window.addEventListener('pointermove', onMove)
  window.addEventListener('pointerup', onUp, { once: true })
}

window.addEventListener('pointerdown', onDown)
