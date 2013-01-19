module Utils {
  server function slog(obj) {
    jlog(Debug.dump(obj))
  }

  client function my_log(obj) {
    #debug =+ Debug.dump(obj)
  }

  function 'b fold_break('a, 'b->option('b) f, list('a) l, 'b acc) {
    match (l) {
      case []:
        acc
      case {~hd, ~tl}:
        match (f(hd, acc)) {
          case {none}:
            acc
          case {~some}:
  	  fold_break(f, tl, some)
        }
    }
  }

  function string prefix(int len, string s) {
    new_len = if (String.length(s) < len) {
      String.length(s)
    } else {
      len;
    }
    String.substr(0, new_len, s)
  }

  /**
   * Given a list, check if all elements are the same.
   */
  function bool list_check_all_same(list('a) l) {
    t = List.fold(
      function('a e, r) {
        if (r.result == false) {
          r;
        } else {
          match (r.elements) {
            case {none}: {elements: {some: e}, result: true}
            case {~some}: if (some == e) { r; } else { {elements: {some: e}, result: false} }
          }
        }
      },
      l,
      {elements: {none}, result: true}
    )
    t.result
  }

  /**
   * Checks if a URI is in a given domain
   */
  function bool is_domain_or_subdomain(Uri.uri uri, string domain) {
    match (uri) {
      case {domain:d, ...}:
        if (d == domain) {
          true;
        } else if (String.has_suffix(".{domain}", d)) {
          true;
        } else {
  	false;
        }
      case _:
        false
    }
  }

  /**
   * Converts a list of 'a into a set of 'a.
   */
  function set('a) list_to_set(list('a) list) {
    List.fold(
      Set.add,
      list,
      Set.empty
    )
  }

  function string list_concat(string el, list(string) l) {
    r = List.fold_right(
      function(option(string) r, string e) {
        match (r) {
          case {none}:
            {some: e}
          case {~some}:
            {some: "{some}{el}{e}"}
        }
      },
      l,
      {none}
    )
    Option.default("", r)
  }

  /**
   * Might be useful?
   */
  function xhtml xhtml_merge(list('a) list) {
    List.fold(
      function(e, r) {
        <>
          {r}
          {e}
        </>
      },
      list,
      <></>
    )
  }
}
