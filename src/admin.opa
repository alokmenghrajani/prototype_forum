/**
 * Module related to administrative tasks (Creating or editing a Hackathon)
 *
 * This code is an ugly mix of controller & view logic
 */
module Admin {
  public function select() {
    content =
      <>
        <h2>Admin mode</h2>
        <a href="/admin/create">Add a hackathon</a>
        | <a href="/admin/tags">Manage tags</a>

        <h2>Drive a forum</h2>
        <ul id=#hackathon_list class="admin nav">
          {render_list()}
        </ul>
      </>

    HackathonModel.register_callback(function() {
      #hackathon_list = render_list()
    })

    View.admin(content)
  }

  private function list(xhtml) render_list() {
    IntMap.fold(
      function(int hackathon_id, hackathon hackathon, list(xhtml) r) {
        List.cons(render_entry(hackathon_id, hackathon), r)
      },
      /prototype_forum/hackathons,
      []
    )
  }

  private function render_entry(int hackathon_id, hackathon hackathon) {
    date_printer = Date.generate_printer("%_d %b %Y")

    <li>
      <i class="icon-chevron-right"/>
      {hackathon.name} ({Date.to_formatted_string(date_printer, hackathon.ts_start)})
      <a href="/forum/{hackathon_id}">control</a>
      | <a href="/presentation/{hackathon_id}">presentation</a>
      | <a href="/register/{hackathon_id}?iknowwhatimdoing">add a project</a>
    </li>
  }

  /**
   * Called from controller, when the admin hits /admin
   */
  function create() {
    ts_start = DateUtils.set_time(Date.now(), 18, 00, 00) // hackathons usually start at 6pm
    ts_end = Date.advance(ts_start, Duration.h(12)) // and last for ~12h

    ts_forum = DateUtils.set_time(ts_end, 13, 00, 00) // forums take place on the following friday at ~1pm
    ts_forum = DateUtils.advance_to_next_weekday(ts_forum, {friday})

    h =
      {
        name: "",
        url: "",
        ~ts_start,
        ~ts_end,
        forum:
        {
          show_forum: false,
          ts_start: ts_forum,
          info: "",
        },
        page_label: "Add a Hackathon",
        submit_label: "Save",
        cancel_url: "/"
      }
    _core(h, do_create)
  }

  function update(int id) {
    hackathon = /prototype_forum/hackathons[id]

    f = if (hackathon.forum.ts_start > Date.milliseconds(0)) {
      {
        show_forum: true,
        ts_start: hackathon.forum.ts_start,
        info: hackathon.forum.info
      }
    } else {
      {
        show_forum: false,
        ts_start: Date.now(),
        info: ""
      }
    }

    h =
      {
        name: hackathon.name,
        url: hackathon.url,
        ts_start: hackathon.ts_start,
        ts_end: hackathon.ts_end,
        forum: f,
        page_label: "Edit a Hackathon",
        submit_label: "Update",
        cancel_url: "/hackathon/{id}"
      }
    _core(h, function(_) {do_update(id)})
  }

  function delete(int hackathon_id) {
    content =
      <div class="alert">
        <p>Are you sure you want to delete this hackathon?</p>
        <button class="btn btn-danger" onclick={function(_){do_delete(hackathon_id)}}>Delete</button>
        <button class="btn btn" onclick={function(_){Client.goto("/hackathon/{hackathon_id}")}}>Cancel</button>
      </div>
    View.admin(content)
  }

  public function resource manage_tags() {
    content =
      <>
        <h2>Tags</h2>
        <div id=#tags class="tag-input">
          {render_existing_tags()}
        </div>
        <div class="form-inline">
          <input id=#tag_input type="text" placeholder="Tag name"/>
          <button class="btn" onclick={tag_add}>Add</button>
        </div>
      </>

    View.admin(content)
  }

  private function tag_add(_) {
    tag_id = Model.gen_next_id()
    tag = {name: Dom.get_value(#tag_input)}
    /prototype_forum/tags[tag_id] <- tag
    Dom.set_value(#tag_input, "")
    #tags =+ render_tag(tag_id, tag)
  }

  private function tag_remove(int tag_id) {
    Db.remove(@/prototype_forum/tags[tag_id])
    Dom.remove(Dom.select_id("{tag_id}"))
  }

  private function list(xhtml) render_existing_tags() {
    tags = /prototype_forum/tags

    List.rev(IntMap.fold(
      function(int id, tag tag, list(xhtml) r) {
        List.cons(render_tag(id, tag), r)
      },
      tags,
      []
    ))
  }

  private function xhtml render_tag(int tag_id, tag tag) {
    <><span id="{tag_id}" class="tag label">{tag.name}
      <button class="close" onclick={function(_){tag_remove(tag_id)}}>×</button>
    </span> </>
  }

  private function do_delete(int hackathon_id) {
    HackathonModel.delete(hackathon_id)
    Client.goto("/?deleted")
  }

  /**
   * Validates input and saves the data
   */
  private function void do_create(_) {
    if (validate()) {
      ts_start = Option.get(WDateTimePicker.get("ts_start"))
      ts_end = Option.get(WDateTimePicker.get("ts_end"))

      forum = if (Dom.is_checked(#forum_checkbox)) {
        {
          ts_start: Option.get(WDateTimePicker.get("forum_ts_start")),
          info: Dom.get_value(#forum_info),
          projects: IntSet.empty,
        }
      } else {
        {
          ts_start: Date.milliseconds(0),
          info: "",
          projects: IntSet.empty
        }
      }

      HackathonModel.create(
        {
          name: Dom.get_value(#name),
          url: Dom.get_value(#url),
          ~ts_start,
          ~ts_end,
          ~forum
        }
      )

      Client.goto("/?created")
    }
  }

  /**
   * Validates the input and updates the data
   */
  function do_update(int hackathon_id) {
   if (validate()) {
      ts_start = Option.get(WDateTimePicker.get("ts_start"))
      ts_end = Option.get(WDateTimePicker.get("ts_end"))

      // TODO: transactions here
      forum = if (Dom.is_checked(#forum_checkbox)) {
        {
          ts_start: Option.get(WDateTimePicker.get("forum_ts_start")),
          info: Dom.get_value(#forum_info),
          projects: /prototype_forum/hackathons[hackathon_id]/forum/projects
        }
      } else {
        {
          ts_start: Date.milliseconds(0),
          info: "",
          projects: /prototype_forum/hackathons[hackathon_id]/forum/projects
        }
      }

      HackathonModel.update(
        hackathon_id,
        {
          name: Dom.get_value(#name),
          url: Dom.get_value(#url),
          ~ts_start,
          ~ts_end,
          ~forum
        }
      )

      Client.goto("/hackathon/{hackathon_id}?updated")
    }
  }

   /**
   * Form logic, shared between create and update
   */
	function _core(data, on_submit) {
    forum_check_box = if (data.forum.show_forum) {
      <input id=#forum_checkbox type="checkbox" checked onchange={handle_forum_checkbox}/>
    } else {
      <input id=#forum_checkbox type="checkbox" onchange={handle_forum_checkbox}/>
    }

    content =
      <>
        <h2>{data.page_label}</h2>
        <div class="row">
          <div class="span12">
            <div class="form-horizontal">
              <fieldset>
                <div class="control-group">
                  <label class="control-label">Name</label>
                  <div class="controls">
                    <input id=#name type="text" class="input-xlarge" value={data.name}/>
                    <div id=#name_error/>
                  </div>
                </div>

                <div class="control-group">
                  <label class="control-label">Event page</label>
                  <div class="controls">
                    <input id=#url type="text" class="input-xlarge" value={data.url}
                      placeholder="https://www.facebook.com/events/1234567890/"
                      onblur={function(_){validate_url(#url, #url_error)}}/>
                    <span id=#url_error/>
                  </div>
                </div>

                <div class="control-group">
                  <label class="control-label">Start date &amp; time</label>
                  <div class="controls">
                    {WDateTimePicker.html("ts_start", data.ts_start)}
                    <span id=#ts_start_error/>
                  </div>
                </div>

                <div class="control-group">
                  <label class="control-label">End date &amp; time</label>
                  <div class="controls">
                    {WDateTimePicker.html("ts_end", data.ts_end)}
                    <span id=#ts_end_error/>
                  </div>
                </div>

                <div class="control-group">
                  <label class="control-label">Forum</label>
                  <div class="controls">
                    <label class="checkbox">
                      {forum_check_box}
                      Allow registration
                    </label>
                  </div>

                  <div id=#forum_controls class="controls {if (data.forum.show_forum==false) "hidden" else ""}">
                    <div class="control-group">
                      <label class="control-label">Date</label>
                      <div class="controls">
                        {WDateTimePicker.html("forum_ts_start", data.forum.ts_start)}
                        <span id=#forum_ts_start_error/>
                      </div>
                    </div>

                    <div class="control-group">
                      <label class="control-label">Info</label>
                      <div class="controls">
                        <input id=#forum_info type="text" class="input-xlarge" placeholder="e.g. location"
                          value={data.forum.info}/>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="form-actions">
                  <button class="btn btn-primary"
                    onclick={on_submit}>{data.submit_label}</button>
                  <button class="btn"
                    onclick={function(_){Client.goto(data.cancel_url)}}>Cancel</button>
                </div>
              </fieldset>
            </div>
          </div>
        </div>
      </>
  	View.admin(content)
	}

  function void validate_datetime(dom el, dom error) {
    p = Date.generate_scanner("%d/%m/%y %H:%M")
    d = Date.of_formatted_string(p, Dom.get_value(el))
    _ = match (d) {
      case {none}:
        Dom.put_inside(
          error,
          Dom.of_xhtml(<div class="alert alert-error">Invalid input. Please use dd/mm/yy hh:mm</div>)
        )
      case {some:_}:
        Dom.put_inside(error, Dom.of_xhtml(<div class="icon-ok"/>))
    }
    void
  }

  function void handle_forum_checkbox(_) {
    if (Dom.is_checked(#forum_checkbox)) {
      Dom.remove_class(#forum_controls, "hidden")
    } else {
      Dom.add_class(#forum_controls, "hidden")
    }
    void
  }

  function void validate_url(dom el, dom error) {
    /**
     * Parses the following strings:
     * http://foo.com/meh -> uri
     * https://foo.com/meh -> uri
     * foo.com/meh -> uri with schema set to http
     */
    function option(Uri.uri) parse_http_or_https(string s) {
      function option(Uri.uri) filter(option(Uri.uri) url) {
        match (url) {
          case {some: {schema:{some:"http"} ...}}: url
          case {some: {schema:{some:"https"} ...}}: url
          case _: {none}
        }
      }

      url = filter(Parser.try_parse(UriParser.uri, s))
      match (url) {
        case {some:_}:
          url
        case {none}:
          filter(Parser.try_parse(UriParser.uri, "http://{s}"))
      }
    }

    // grab the data
    url = Dom.get_value(el)

    // validate the URL
    potential_url = parse_http_or_https(url)
    _ = match (potential_url) {
      case {some:_}:
        Dom.put_inside(error, Dom.of_xhtml(<div class="icon-ok"/>))
      case {none}:
        Dom.put_inside(
          error,
          Dom.of_xhtml(<div class="alert alert-error">Invalid URL.</div>)
        )
    }
    void
  }

  /**
   * Validates data
   */
  function bool validate() {
   r = if (Dom.get_value(#name) == "") {
      #name_error = <div class="alert alert-error">Please baptise your hackathon</div>
      false
    } else {
      #name_error = <></>
      true
    }
    r = r && if (WDateTimePicker.get("ts_start") == {none}) {
      #ts_start_error = <div class="alert alert-error">Please set a valid start date/time</div>
      false
    } else {
      #ts_start_error = <></>
      true
    }
    r = r && if (WDateTimePicker.get("ts_end") == {none}) {
      #ts_end_error = <div class="alert alert-error">Please set a valid end date/time</div>
      false
    } else {
      #ts_end_error = <></>
      true
    }

    // TODO: check that the end date is > start date

    r && if (Dom.is_checked(#forum_checkbox) && (WDateTimePicker.get("forum_ts_start") == {none})) {
      #forum_ts_start_error = <div class="alter alert-error">Please set a valid forum start date/time</div>
      false
    } else {
      #forum_ts_start_error = <></>
      true
    }
  }
}
