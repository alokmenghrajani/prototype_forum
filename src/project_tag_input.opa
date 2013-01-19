/**
 * A html auto-completion for tags
 *
 * Lots of copy-pasta :(
 */

module ProjectTagInput {
  /**
   * Renders the widget.
   */
  function xhtml html(string dom_id, list((int, string)) initial_values) {
    tags = IntMap.fold(
      function(id, tag, r) {
        List.cons((id, tag.name), r)
      },
      /prototype_forum/tags,
      []
    )

    config =
      {WCompletion.default_config with suggest: _create_suggest(tags)}

    <div class="tag-input">
      <div id={dom_id} class="main">
        <span id="{dom_id}_tags">{_process_initial_tags(dom_id, initial_values)}</span>
        <span id="{dom_id}_data" class="hidden">{_process_initial_data(initial_values)}</span>
        {WCompletion.html(
          config,
          function(o){_on_select(o, dom_id)},
          dom_id,
          {input: "", display: <h2>none</h2>, item: {none}}
        )}
      </div>
    </div>
  }

  function list(xhtml) _process_initial_tags(string dom_id, list((int, string)) values) {
    List.map(
      function(e) {
        _gen_tag(dom_id, e.f1, e.f2)
      },
      values
    )
  }

  function string _process_initial_data(list((int, string)) values) {
    tags = List.map(function(e){e.f1}, values)
    _serialize_tags(tags)
  }

  /**
   * Given a dom_id, returns the list of tags which have been selected.
   */
  client function list(int) get_tags(string dom_id) {
    r = Dom.get_text(Dom.select_id("{dom_id}_data"))
    // TODO: figure out how to do something like:
    // OpaSerialize.unserialize_unsafe(r, @typeval(list(int)))
    List.map(
      function(s){Int.of_string(s)},
      String.explode("|", r)
    )
  }

  function _create_suggest(dict) {
    // Note: there's a bug in the Opa compiler and we need to assign things to a variable
    // and return the variable here.
    // See http://forum.opalang.org/1_475
    r = @public_env(_suggest(_, dict))
    r
  }

  function _suggest(string input, dict) {
    int len = String.length(input)
    string lower_input = String.to_lower(input)

    r = List.fold(
      function (e, r) {
        if (String.to_lower(Utils.prefix(len, e.f2)) == lower_input) {
          if (r.f1<10) {
            (r.f1+1, List.cons(
              {
                input: input,
                display: <h4>{e.f2}</h4>,
                item: {some: e}
              },
              r.f2
            ))
          } else {
            r;
          }
        } else {
          r;
        }
      },
      dict,
      (0, [])
    )
    r.f2
  }

  function string _serialize_tags(list(int) tags) {
    String.concat("|", List.map(function(i){"{i}"}, tags))
  }

  client function void _set_tag(string dom_id, int tag_id) {
    l = get_tags(dom_id)
    l = List.cons(tag_id, l)
    Dom.set_text(
      Dom.select_id("{dom_id}_data"),
      //OpaSerialize.serialize(l)
      _serialize_tags(l)
    )
  }

  client function void _remove_tag(string dom_id, int tag_id) {
    Dom.remove(Dom.select_id("{dom_id}_{tag_id}"))
    l = get_tags(dom_id)
    l = List.filter(
      function(x) { x != tag_id },
      l
    )
    Dom.set_text(
      Dom.select_id("{dom_id}_data"),
      //OpaSerialize.serialize(l)
      _serialize_tags(l)
    )
  }

  client function void _on_select(opt, string dom_id) {
    input = Dom.select_id("{dom_id}_input")
    match (opt) {
      case {~some}:
        // check if the tag is already part of the data
        l = get_tags(dom_id)
        tag_id = some.f1
        if (List.mem(tag_id, l) == false) {
          tag = _gen_tag(dom_id, tag_id, some.f2)
          _ = Dom.put_at_end(
            Dom.select_id("{dom_id}_tags"),
            Dom.of_xhtml(tag)
          )
          _set_tag(dom_id, tag_id)
        }
        void
      case {none}:
        void
    }
    Dom.set_value(input, "")
  }

  function xhtml _gen_tag(string dom_id, int tag_id, string label) {
    <span id="{dom_id}_{tag_id}" class="tag label">{label}
      <button class="close" type="button"
        onclick={function(_){_remove_tag(dom_id, tag_id)}}>×</button>
    </span>
  }
}







































