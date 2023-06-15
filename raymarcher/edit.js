import { basicSetup } from 'codemirror'

import { EditorState } from '@codemirror/state'
import { EditorView, keymap } from '@codemirror/view'
import { getShader, setShader } from './gl'

let codemirror = null

const initCodeMirror = () => {
  const onChange = EditorView.updateListener.of(v => {
    if (v.docChanged && !v.transactions.some(t => t.isUserEvent('url'))) {
      setShader(v.state.doc.toString())
    }
  })

  const startState = EditorState.create({
    doc: getShader(),
    extensions: [basicSetup, onChange],
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
