/**
 * Module related to Uri manipulation.
 *
 * I feel Opa's stdlib Uri is poor in terms of creating & mutating Uris, so I wrote this.
 */

type UriUtils.uri =
  { Uri.absolute absolute } or
  { Uri.relative relative}

module UriUtils {
  public function UriUtils.uri of_string(string uri) {
    u = Option.get(Uri.of_string(uri))
    match (u) {
      case {~schema, ~credentials, ~domain, ~port,
            ~path, ~fragment, ~query, ~is_directory}:
        {absolute: {~schema, ~credentials, ~domain, ~port,
          ~path, ~fragment, ~query, ~is_directory}}
      case {~path, ~fragment, ~query, ~is_directory, ~is_from_root}:
        {relative: {~path, ~fragment, ~query, ~is_directory, ~is_from_root}}
      case _:
        @fail("UriUtils.of_string called with invalid input")
    }
  }

  public function string to_string(UriUtils.uri uri) {
    match (uri) {
      case {absolute: uri}:
        Uri.to_string(Uri.of_absolute(uri))
      case {relative: uri}:
        Uri.to_string(Uri.of_relative(uri))
    }
  }

  public function UriUtils.uri of_relative(Uri.relative uri) {
    {relative: uri}
  }

  public function UriUtils.uri of_absolute(Uri.absolute uri) {
    {absolute: uri}
  }

  /**
   * Most useful when you want to take an absolute base uri
   * and set the path/query/etc. with the content of a relative uri
   */
  public function UriUtils.uri replace(UriUtils.uri base, UriUtils.uri extra) {
    t = (base, extra)
    match (t) {
      case {f1: _, f2: {absolute:_}}:
        extra
      case {f1: {relative:_}, f2: {relative:_}}:
        extra
      case {f1: {absolute: base}, f2: {relative: extra}}:
        new_uri = {base with
          path:extra.path, fragment: extra.fragment, query: extra.query, is_directory: extra.is_directory}
        {absolute: new_uri}
    }
  }

  public function list((string, string)) getQuery(UriUtils.uri uri) {
    match (uri) {
      case {absolute: uri}:
        uri.query
      case {relative: uri}:
        uri.query
    }
  }

  public function UriUtils.uri setQuery(UriUtils.uri uri, list((string, string)) query) {
    match (uri) {
      case {absolute: uri}:
        {absolute: {uri with ~query}}
      case {relative: uri}:
        {relative: {uri with ~query}}
    }
  }

  /**
   * Adds a key/value.
   *
   * Note: this can lead to duplicate keys.
   */
  public function UriUtils.uri addQueryData(UriUtils.uri uri, string key, string value) {
    query = [(key, value) | getQuery(uri)]
    setQuery(uri, query)
  }

  /**
   * Very similar to addQueryData but takes a Uri.uri as the value.
   */
  public function UriUtils.uri addQueryUrl(UriUtils.uri uri, string key, UriUtils.uri value) {
    v = to_string(value)
    addQueryData(uri, key, v)
  }

  /**
   * Get's the value of a given key.
   *
   * TODO: document what happens if a key is duplicate
   */
  public function option(string) getValue(UriUtils.uri uri, string key) {
    map = Map.From.assoc_list(getQuery(uri))
    Map.get(key, map)
  }

  /**
   * TODO: check how this works with multiple keys
   */
  public function UriUtils.uri removeKey(UriUtils.uri uri, string key) {
    map = Map.From.assoc_list(getQuery(uri))
    map = Map.remove(key, map)
    setQuery(uri, Map.To.assoc_list(map))
  }
}


