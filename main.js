import { initEdit } from './raymarcher/edit'
import { initGL, render, sizeGL } from './raymarcher/gl'

window.addEventListener('resize', sizeGL)

window.addEventListener('DOMContentLoaded', () => {
  const canvas = document.getElementById('gl')
  initGL(canvas)
  initEdit()
  render()
})
