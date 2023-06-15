import {
  compressToEncodedURIComponent,
  decompressFromEncodedURIComponent,
} from 'lz-string'

export const updateTitle = title => {
  document.title = title
}

export const setUrlFromSource = source => {
  const current = window.location.search.slice(1)
  const next = compressToEncodedURIComponent(source)
  if (current !== next) {
    window.history.pushState({}, '', `?${next}`)
  }
}

export const getSourceFromUrl = () => {
  return decompressFromEncodedURIComponent(window.location.search.slice(1))
}
