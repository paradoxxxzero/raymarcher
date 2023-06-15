import glsl from 'vite-plugin-glsl'

export default {
  base: '',
  plugins: [
    glsl({
      compress: false,
    }),
  ],
  build: {
    outDir: 'docs',
  },
  server: {
    port: 17171,
  },
}
