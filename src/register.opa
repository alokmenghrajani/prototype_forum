/**
 * The module that takes care of the form used to register a Hack.
 */
module Register {
	/**
	 * Render a warning before users register their hack.
	 */
	function warning(int hackathon_id) {
		content =
		  <>
		  	<h1>Please read</h1>
		  	<p>Please make sure you read the following instructions before signing up for the prototype forum.</p>

		  	<h3>What is the Prototype Forum?</h3>
		  	<p>
		  		The forum is your opportunity to give a 2 minutes live demo of what you
					built during the hackathon (and get a tshirt for it).
				</p>

				<h3>Why should I sign up?</h3>
				<p>
				  By signing up for the Forum, you will get an opportunity to show what you built and inspire your peers.
				</p>
				<p>
				  If you think 2 minutes is not enough, please give a brief overview of what you built and point people to
				  a webpage or some other resource.
				</p>

				<h3>Can I present slides (PowerPoint, etc.)?</h3>
				<p>
				  No. The point of Hackathons is to get people to work on things they usually don't work on. We want to see
				  what you are able to achieve in a single night, and we want your prototype to be the starting point for
				  our next great product! It's ok to use slides along with your live demo, but we don't want people to spend
				  their Hackathons making shiny slides.
				</p>

				<a href="/register/{hackathon_id}?iknowwhatimdoing" class="btn btn-primary btn-small">
				  <i class="icon-plus icon-white"/>
				  I want to register my hack
				</a>
			</>
		View.warning(content)
	}

	/**
	 * Renders registration form.
	 */
	function create(int hackathon_id) {
		data =
		{
			title: "",
			planned: "",
			achieved: "",
			location: "",
			contributors: IntSet.add(UserModel.get(), IntSet.empty),
			links: [],
      tags: IntSet.empty,
			on_submit: function(){do_create(hackathon_id)},
		}
		_core(hackathon_id, data)
	}

	function update(int hackathon_id, int project_id) {
		project p = /prototype_forum/projects[project_id]

		data =
		{
			title: p.title,
			planned: p.planned,
			achieved: p.achieved,
			location:  Model.location_to_string(p.location),
			contributors: p.contributors,
			links: p.links,
      tags: p.tags,
			on_submit: function(){do_update(hackathon_id, project_id, p.flagged, p.weight)},
		}

		_core(hackathon_id, data)
	}

	function delete(int hackathon_id, int project_id) {
		content =
		  <div class="alert">
		    <p>Are you sure you want to delete your project?</p>
		    <button class="btn btn-danger" onclick={function(_){do_delete(hackathon_id, project_id)}}>Delete</button>
		    <button class="btn btn" onclick={function(_){Client.goto("/hackathon/{hackathon_id}")}}>Cancel</button>
		  </div>
		View.register(content)
	}

	function do_delete(int hackathon_id, int project_id) {
    ProjectsModel.delete(hackathon_id, project_id)
  	Client.goto("/hackathon/{hackathon_id}?deleted")
	}

	function list(xhtml) _build_options(list((string, string)) list, string selected) {
		List.map(
			function(e) {
 				if (e.f1 == selected) {
  				<option value={e.f1} selected="selected">{e.f2}</option>
				} else {
          <option value={e.f1}>{e.f2}</option>
				}
			},
			list
		)
	}


	function _core(int hackathon_id, data) {
		// for every contributor, convert the data into a tuple
    contributors = List.rev(IntSet.fold(
			function(id, r) {
				List.cons((id, /prototype_forum/people[id]/name), r)
			},
			data.contributors,
			[]
		))

    // Same with tags
    tags = List.rev(IntSet.fold(
      function(id, r) {
        List.cons((id, /prototype_forum/tags[id]/name), r)
      },
      data.tags,
      []
    ))

		(location, location2) =
			if (String.has_prefix("mpk", data.location)) {
			  ("mpk", Option.get(String.get_suffix(String.length(data.location) - 4, data.location)))
      } else {
		    (data.location, "shared")
		  }

		options = _build_options(
			[("", "Select where you'll be presenting from"),
			 ("newyork", "New York"),
			 ("seattle", "Seattle"),
			 ("london", "London"),
			 ("mpk", "Menlo Park")],
			location);

		radio1 = if (location2 == "shared") {
			<input type="radio" checked="" value="shared" name="presentation_type"/>
		} else {
			<input type="radio" value="shared" name="presentation_type"/>
		}

		radio2 = if (location2 == "projector") {
      <input type="radio" checked="" value="projector" name="presentation_type"/>
		} else {
			<input type="radio" value="projector" name="presentation_type"/>
		}

		radio3 = if (location2 == "laptop") {
      <input type="radio" checked="" value="laptop" name="presentation_type"/>
		} else {
			<input type="radio" value="laptop" name="presentation_type"/>
		}

	  presentation_type = if (location == "mpk") {
			"";
	  } else {
	  	"hidden";
	  }

		links = Utils.xhtml_merge(List.map(function(e){render_link(e.f1, e.f2)}, data.links))

		content =
      <>
        <h2>Register your Hack</h2>
        <div class="row">
          <div class="span12">
            <div id=#registration_form class="form-horizontal">
              <fieldset>
                <div id=#page1>
                  <h3>About your work</h3>
                  <div class="control-group">
                    <label class="control-label">Project title</label>
                    <div class="controls">
                      <input id=#title type="text" class="input-xxlarge"
                        value={data.title}
                        placeholder="Something short but descriptive"/>
                      <div id=#title_error/>
                    </div>
                  </div>

                  <div class="control-group">
                    <label class="control-label">What was your goal?</label>
                    <div class="controls">
                      <textarea id=#planned rows="3" class="input-xxlarge">{data.planned}</textarea>
                      <div id=#planned_error/>
                    </div>
                  </div>

                  <div class="control-group">
                    <label class="control-label">How much did you achieve?</label>
                    <div class="controls">
                      <textarea id=#achieved rows="3" class="input-xxlarge">{data.achieved}</textarea>
                      <div id=#achieved_error/>
                    </div>
                  </div>

                  <div class="control-group">
                    <label class="control-label">Who did you work with?</label>
                    <div class="controls">
                      {EmployeeTagInput.html("people", contributors)}
                      <div id=#people_error/>
                    </div>
                  </div>

                  <div class="control-group">
                    <label class="control-label">Tags</label>
                    <div class="controls">
                      {ProjectTagInput.html("tags", tags)}
                    </div>
                  </div>

                  <div class="form-actions">
                    <button class="btn btn-primary" onclick={goto_page2}>Next</button>
                    <button class="btn" onclick={function(_){Client.goto("/hackathon/{hackathon_id}")}}>Cancel</button>
                  </div>
                </div>

                <div id=#page2 class="hidden">
                  <h3>Presentation information</h3>
                  <div class="control-group">
                    <label class="control-label">Location</label>
                    <div class="controls">
                      <select id=#location onchange={handle_location}>
                        {options}
                      </select>
                      <div id=#location_error/>
                    </div>
                  </div>

                  <div id=#presentation_type class="control-group {presentation_type}">
                    <label class="control-label">Presentation type</label>
                    <div class="controls">
                      <div class="text_thumbnail">
                        <div>Shared computer</div>
                        <span>
                          The simplest presentation type. Demo on Firefox.
                        </span>
                        {radio1}
                      </div>

                      <div class="text_thumbnail">
                        <div>Projector</div>
                        <span>
                          Ideal for demos built on phones, tablets, or any small device.
                        </span>
                        {radio2}
                      </div>

                      <div class="text_thumbnail">
                        <div>Own computer</div>
                        <span>
                          Please choose this option if you have a strong reason to.
                        </span>
                        {radio3}
                      </div>
                    </div>
                  </div>

                  <div class="control-group">
                    <label class="control-label">Links</label>
                    <div class="controls">
                      <button class="btn btn-small"
                        onclick={function(_){
                        	Dom.remove_class(#add_url, "hidden")
                        	Dom.add_class(#add_file, "hidden")
                      }}>Add a url</button>
                      <button class="btn btn-small"
                        onclick={function(_){
                        	Dom.remove_class(#add_file, "hidden")
                        	Dom.add_class(#add_url, "hidden")
                        }}>Add a file (powerpoint,
                          video, screenshots, ...). Max 10 MB!</button>

                      <div class="dialog hidden" id=#add_file>
                        <h4>Add a file</h4>
                        <div class="control-group">
                          {Upload.html({Upload.default_config() with
                            form_body:
                              <>
                                <label  class="control-label">Title</label>
                                <div class="controls">
                                  <input id=#add_file_title name="title" type="text" class="input-xlarge"/>
                                </div>
                                <label class="control-label">File</label>
                                <div class="controls">
                                  <input type="file" class="input-file" id=#file_upload name="upload"/>
                                </div>
                                <div class="controls" style="text-align: right; width: 280px">
                                  <button class="btn btn-small btn-primary">Upload</button>
                                </div>
                              </>,
                            process: handle_file_upload
                          })}
                          <button class="btn btn-small"
                            onclick={function(_){handle_add_file_cancel()}}>Cancel</button>
                        </div>
                      </div>

                      <div id=#add_url class="dialog hidden">
                        <h4>Add a url</h4>
                        <div class="control-group">
                          <label  class="control-label">Title</label>
                          <div class="controls">
                            <input id=#add_url_title type="text" class="input-xlarge"/>
                          </div>
                          <label class="control-label">Url</label>
                          <div class="controls">
                            <input id=#add_url_url type="text" class="input-xlarge"/>
                            <div id=#add_url_error/>
                          </div>
                          <div class="controls" style="text-align: right; width: 280px">
                            <button class="btn btn-small btn-primary"
                              onclick={handle_add_url_ok}>Ok</button>
                            <button class="btn btn-small"
                              onclick={handle_add_url_cancel}>Cancel</button>
                          </div>
                        </div>
                      </div>
                      <div id=#links>{links}</div>
                    </div>
                  </div>

                  <div class="form-actions">
                    <button class="btn btn-primary" onclick={function(_){data.on_submit()}}>Save</button>
                    <button class="btn" onclick={goto_page1}>Back</button>
                  </div>
                </div>
              </fieldset>
            </div>
          </div>
        </div>
      </>

		View.register(content)
	}

  /**
   * Called when the user goes from page 1 to page 2.
   */
  function void goto_page2(_) {
    // validate form
    if (validate_page1()) {
      // switch page
      Dom.add_class(#page1, "hidden")
      Dom.remove_class(#page2, "hidden")
    }
  }

  function bool validate_page1() {
    r = if (Dom.get_value(#title) == "") {
      #title_error = <div class="alert alert-error">Please enter a title</div>
      false
    } else {
      #title_error = <></>
      true
    }
    r = r && if (Dom.get_value(#planned) == "") {
      #planned_error = <div class="alert alert-error">Please describe your goals</div>
      false
    } else {
      #planned_error = <></>
      true
    }
    r = r && if (Dom.get_value(#achieved) == "") {
      #achieved_error = <div class="alert alert-error">Please describe how much you achieved</div>
      false
    } else {
      #achieved_error = <></>
      true
    }
    r = r && if (List.is_empty(EmployeeTagInput.get_tags("people"))) {
      #people_error = <div class="alert alert-error">Please list at least one contributor</div>
      false
    } else {
      #people_error = <></>
      true
    }
    r
  }

  function bool validate_page2() {
    r = if (Dom.get_value(#location) == "") {
      #location_error = <div class="alert alert-error">Please select your location</div>
      false
    } else {
      #location_error = <></>
      true
    }
    r
  }

  /**
   * Called when the user cancels on page 2.
   */
  function void goto_page1(_) {
  // don't clear data, the user might want to preserve things...
  //    Dom.set_value(#location, "")
  //    #links = <></>
  //    Dom.add_class(#presentation_type, "hidden")
    Dom.add_class(#page2, "hidden")
    Dom.remove_class(#page1, "hidden")
	}

  /**
   * Called when the location field changes
   */
  function void handle_location(_) {
    if (Dom.get_value(#location) == "") {
      #location_error = <div class="alert alert-error">Please select your location</div>
    } else {
      #location_error = <></>
    }

    if (Dom.get_value(#location) == "mpk") {
      Dom.remove_class(#presentation_type, "hidden")
    } else {
      Dom.add_class(#presentation_type, "hidden")
    }
  }

  /**
   * Called when the user adds a file.
   *
   * Stores the file in the DB and returns a url.
   */
  function void handle_file_upload(upload_data) {
    (_, file) = StringMap.min_binding(upload_data.uploaded_files)
    filename = file.filename
    mimetype = file.mimetype
    title = Option.default("", StringMap.get("title", upload_data.form_fields))
    title = if (title == "") file.filename else title

    data = file.content
    md5 = Crypto.Hash.md5(string_of_binary(file.content))
    /prototype_forum/files[md5] <- {
      ~filename,
      ~data,
      ~mimetype
    }

    // add the file to the form
    add_link(title, Option.get(Uri.of_string("/files/{md5}")))

    // hide the dialog
    handle_add_file_cancel();
  }

  /**
   * Called when the user cancels an add file action
   */
  function void handle_add_file_cancel() {
    // hide the dialog
    Dom.add_class(#add_file, "hidden")
    // clear fields
    Dom.set_value(#file_upload, "")
    Dom.set_value(#add_file_title, "")
  }

  /**
   * Called when the user adds a URL
   */
  function void handle_add_url_ok(Dom.event e) {
    /**
     * Called when the URL is valid
     */
    function pass(Uri.uri url, string title) {
      // add the URL to the form
      add_link(title, url)

      // hide the dialog
      handle_add_url_cancel(e)
    }
    /**
     * Called when the URL is invalid
     */
    function fail(_) {
      #add_url_error = <div class="alert alert-error">Sorry, this URL is not valid.</div>
    }
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
    url = Dom.get_value(#add_url_url)
    // validate the URL
    potential_url = parse_http_or_https(url)
    match (potential_url) {
       case {~some}:
          title = Dom.get_value(#add_url_title)
          title = if (title == "") Uri.to_string(some) else title
          pass(some, title)
       case {none}: fail(potential_url)
    }
  }

  function render_link(string title, string url) {
  	id = Dom.fresh_id()
  	<div id={id}>
      <button class="close" onclick={function(e){remove_link(e, id)}}>×</button>
      <a href="{url}" target="_blank">{title}</a>
      <div class="alink hidden">{OpaSerialize.serialize((title, url))}</div>
    </div>
  }

  /**
   * Called when a link is added
   */
  function void add_link(string title, Uri.uri url) {
    normalized_url = Uri.to_string(url)
    #links =+ render_link(title, normalized_url)
  }

  /**
   * Extract links from #links
   */
  function list((string, string)) get_links() {
    List.rev(Dom.fold(
      function(dom link, r) {
      	v = OpaSerialize.unserialize_unsafe(Dom.get_text(link), @typeval((string, string)))
      	List.cons(v, r)
      },
      [],
      Dom.select_class("alink")
    ))
  }

  /**
   * Called when the user removes a link
   */
  function void remove_link(_, string id) {
    Dom.remove(Dom.select_id(id))
  }

  /**
   * Called when the user cancels an add URL action
   */
  function void handle_add_url_cancel(_) {
    // hide the dialog
    Dom.add_class(#add_url, "hidden")

    // reset the input fields
    Dom.set_value(#add_url_title, "")
    Dom.set_value(#add_url_url, "")
    #add_url_error = ""
  }

	function void do_create(int hackathon_id) {
    if (_do_core(hackathon_id, {none}, false, 10000)) {
     	Client.goto("/hackathon/{hackathon_id}?created")
    }
  }

  function void do_update(int hackathon_id, int project_id, bool flagged, int weight) {
  	if (_do_core(hackathon_id, {some: project_id}, flagged, weight)) {
     	Client.goto("/hackathon/{hackathon_id}?updated")
    }
  }

  function location get_location() {
  	location = Dom.get_value(#location)
  	r = if (location == "mpk") {
		  nodes = Dom.select_raw("[name=presentation_type]")
      // TODO: improve this!
		  r = Dom.fold(
		    function(e,	r) {
		      if (Dom.is_checked(e)) {
						{some: Dom.get_value(e)}
		      } else {
						r;
		      }
		    },
		    {none},
		    nodes
		  )
  		"{location}_{Option.get(r)}"
  	} else {
  		location;
  	}
    Model.string_to_location(r)
  }

  client function bool _do_core(int hackathon_id, option(int) project_id, bool flagged, int weight) {
		// validate page2
    if (validate_page2()) {
      links = get_links()
      location = get_location()

      // save the data
    	project p =
    	{
    		title: Dom.get_value(#title),
    		planned: Dom.get_value(#planned),
    		achieved: Dom.get_value(#achieved),
    		audit: UserModel.get(),
    		~location,
    		contributors: Utils.list_to_set(EmployeeTagInput.get_tags("people")),
    		~links,
    		flagged: flagged,
        weight: weight,
        tags: Utils.list_to_set(ProjectTagInput.get_tags("tags")),
    	}

      match (project_id) {
        case {none}:
          ProjectsModel.create(hackathon_id, p)
        case {~some}:
          ProjectsModel.update(hackathon_id, some, p)
      }
      true
    } else {
      false;
    }
  }
}
