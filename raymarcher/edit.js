import { basicSetup } from 'codemirror'
import { cpp } from '@codemirror/lang-cpp'
import { EditorState } from '@codemirror/state'
import { EditorView, keymap } from '@codemirror/view'
import { getShader, setShader } from './gl'
import { oneDark } from '@codemirror/theme-one-dark'
import { linter } from '@codemirror/lint'
import fragmentSource from './fragment.glsl'

let codemirror = null
const shift = fragmentSource.split('##SHADER##')[0].split('\n').length

const compilerLinter = linter(view => {
  const { doc } = view.state
  const diagnostics = []
  const error = setShader(doc.toString())
  if (error) {
    const errorRE = /ERROR: (\d+):(\d+): (.*)/g
    let parsed
    while ((parsed = errorRE.exec(error))) {
      const [, column, line, message] = parsed
      diagnostics.push({
        from: doc.line(+line + 1 - shift).from + +column,
        to: doc.line(+line + 2 - shift).from - 1,
        severity: 'error',
        message,
      })
    }
  }
  return diagnostics
})

const closeOnEscape = keymap.of([
  {
    key: 'Escape',
    run: () => {
      const editor = document.getElementById('editor')
      editor.style.display = 'none'
    },
  },
])

const initCodeMirror = () => {
  const startState = EditorState.create({
    doc: getShader(),
    extensions: [basicSetup, oneDark, cpp(), compilerLinter, closeOnEscape],
  })

  codemirror = new EditorView({
    state: startState,
    parent: document.getElementById('editor'),
  })
}

export const initEdit = () => {
  const editor = document.getElementById('editor')
  const toggler = document.getElementById('edit')
  toggler.addEventListener('click', () => {
    if (!codemirror) {
      initCodeMirror()
    }
    editor.style.display = editor.style.display !== 'block' ? 'block' : 'none'
  })
}

export const setEditSource = source => {
  if (codemirror) {
    codemirror.dispatch({
      changes: {
        from: 0,
        to: codemirror.state.doc.length,
        insert: source,
      },
      userEvent: 'url',
    })
  }
}
