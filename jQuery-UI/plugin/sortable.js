/**
 * @externType dom_element
 * @register { dom_element, (void -> void) -> void }
 */
function mk_sortable(dom, cb) {
  dom.sortable({stop: cb})
}
