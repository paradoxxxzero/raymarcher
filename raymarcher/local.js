const defaultPrefs = {
  pause: null,
  edit: null,
}

export const getPref = key => {
  const prefs = JSON.parse(localStorage.getItem('prefs')) || defaultPrefs
  return prefs[key]
}

export const setPref = (key, value) => {
  const prefs = JSON.parse(localStorage.getItem('prefs')) || defaultPrefs
  prefs[key] = value
  localStorage.setItem('prefs', JSON.stringify(prefs))
}
