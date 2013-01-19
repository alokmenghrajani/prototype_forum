package window

module Window {
  function open(string name, string url) {
  	%%External_window_open%%(name, url)
  }

  function close_all() {
    %%External_window_close_all%%()
  }

  function setItem(string key, string value) {
    %%External_window_setItem%%(key, value)
  }

  function getItem(string key) {
    %%External_window_getItem%%(key)
  }
}
