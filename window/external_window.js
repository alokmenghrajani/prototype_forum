/**
 * @register { -> void }
 */
function close_all() {
	for (var k in window.child_windows) {
		window.child_windows[k].close()
		delete window.child_windows[k]
	}
}

/**
 * @register { string, string -> void }
 */
function open(url, name) {
	handle = window.open(url, name)
	if (!window.child_windows) {
  	  window.child_windows = {}
  	}
	window.child_windows[name] = handle
}

/**
 * This doesn't belong here, but I'm lazy.
 *
 * @register { string, string -> void }
 */
function setItem(key, value) {
  localStorage.setItem(key, value)
}

/**
 * @register { string -> string }
 */
function getItem(key) {
  return localStorage.getItem(key)||""
}
