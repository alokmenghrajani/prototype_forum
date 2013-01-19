package jquery.sortable

module Sortable {
 function mk_sortable(dom, (void -> void) cb) {
    %%Sortable.mk_sortable%%(Dom.of_selection(dom), cb)
  }
}
