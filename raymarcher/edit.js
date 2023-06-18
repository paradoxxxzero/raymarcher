import { basicSetup } from 'codemirror'
import { cpp } from '@codemirror/lang-cpp'
import { EditorState } from '@codemirror/state'
import { indentWithTab } from '@codemirror/commands'
import { foldAll, ensureSyntaxTree } from '@codemirror/language'
import { EditorView, keymap } from '@codemirror/view'
import { getShader, setShader } from './gl'
import { oneDark } from '@codemirror/theme-one-dark'
import { linter } from '@codemirror/lint'
import fragmentSource from './fragment.glsl'

let codemirror = null
let currentError = null
const shift = fragmentSource.split('##SHADER##')[0].split('\n').length

const compilerLinter = linter(view => {
  const { doc } = view.state
  const diagnostics = []
  if (currentError) {
    const errorRE = /ERROR: (\d+):(\d+): (.*)/g
    let parsed
    while ((parsed = errorRE.exec(currentError))) {
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

const onChange = EditorView.updateListener.of(v => {
  if (v.docChanged && !v.transactions.some(t => t.isUserEvent('url'))) {
    currentError = setShader(v.state.doc.toString())
  }
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
    extensions: [
      basicSetup,
      keymap.of([indentWithTab]),
      oneDark,
      cpp(),
      onChange,
      compilerLinter,
      closeOnEscape,
    ],
  })

  codemirror = new EditorView({
    state: startState,
    parent: document.getElementById('editor'),
  })

  //   ensureSyntaxTree(codemirror.state, codemirror.state.doc.length, 5000)
  //   codemirror.dispatch({})
  //   foldAll(codemirror)
}

export const initEdit = () => {
  const editor = document.getElementById('editor')
  const toggler = document.getElementById('edit')
  toggler.addEventListener('click', () => {
    if (!codemirror) {
      initCodeMirror()
    }
    editor.style.display = editor.style.display !== 'block' ? 'block' : 'none'
    toggler.innerHTML = editor.style.display === 'block' ? '❌' : '✏️'
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
