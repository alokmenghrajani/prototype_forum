/**
 * The code to reorder hacks and drive the presentations.
 */
module Forum {
  /**
   * Show a list of hackathons, and let the user select which one to "drive".
   */
  function forum_select() {
    render_link = function(hackathon_id) {
      "/forum/{hackathon_id}"
    }

		content =
			<>
			  <h2>"drive" a hackathon</h2>
			  <p>This interface lets you select which project gets rendered on the presention laptop.</p>

        {HackathonView.render_list(render_link)}
	    </>

  	View.forum(content)
  }

  function toggle_flag(string dom_id, int project_id) {
  	flag = not(/prototype_forum/projects[project_id]/flagged)
  	/prototype_forum/projects[project_id]/flagged <- flag

  	dom = Dom.select_id(dom_id)
  	if (flag) {
  		Dom.set_class(dom, "icon-ok")
    } else {
    	Dom.set_class(dom, "icon-flag")
    }
  }

  function select_hack(int hackathon_id, int project_id) {
  	// Remove highlights on all the elements
  	_ = Dom.fold(
  		function (e, r) {
  			Dom.remove_class(e, "active_cell")
  			r
  		},
  		0,
  	  Dom.select_class("active_cell")
  	)


    ProjectsModel.update_selected(hackathon_id, project_id)
  	Dom.add_class(Dom.select_id("{project_id}"), "active_cell")
  }

  function project_cmp(project p1, project p2) {
    if (p1.weight > p2.weight) {
      {gt}
    } else if (p1.weight < p2.weight) {
      {lt}
    } else {
      {eq}
    }
  }


  function list(xhtml) forum_render_projects(int hackathon_id) {
    selected_project = /prototype_forum/selected[hackathon_id]
    sorted_and_grouped_projects = ProjectsModel.get(hackathon_id)
    locations = Model.get_locations()

    List.map(
      function(location) {
        <>
          {Model.location_to_xhtml(location)}
          {render_projects_for_location(hackathon_id, location, sorted_and_grouped_projects, selected_project)}
        </>
      },
      locations
    )
  }

  private function render_projects_for_location(int hackathon_id, location location, sorted_and_grouped_projects, selected_project) {
    projects = Option.default([], Map.get(location, sorted_and_grouped_projects))

    List.fold(
      function (project, r) {
        int project_id = project.id
        project p = project.project

        flag_dom_id = Dom.fresh_id()

        flag = if (p.flagged) { "icon-ok"; } else { "icon-flag"; }
        active_cell = if (project_id == selected_project) {
          "active_cell";
        } else {
          "";
        }
        <>
          {r}
          <li id="{project_id}" class="ui-state-default {active_cell}">
            <div class="well">
              <div class="close">
                <a class="select" onclick={function(_){select_hack(hackathon_id, project_id)}}>
                  Select
                </a>
                <a onclick={function(_){toggle_flag(flag_dom_id, project_id)}}>
                  <i id={flag_dom_id} class="{flag}"></i>
                </a>
              </div>

              {ProjectsView.render_contributors_pics(p)}
              <h3>{p.title}
                <small>By: {ProjectsView.render_contributors_list(p)}</small>
              </h3>
              <h4>Planned</h4>
              <p>{p.planned}</p>
              <h4>Achieved</h4>
              <p>{p.achieved}</p>
              <p>{ProjectsView.render_links(p)}</p>
            </div>
          </li>
        </>
      },
      projects,
      <></>
    )
  }

  function forum(int hackathon_id) {
   	content =
	    <div class="demo" onready={function(_) { Sortable.mk_sortable(#sortable,
        function(_){save_order(hackathon_id)})}}>
	      <ul class="unstyled" id=#sortable>
	      	{forum_render_projects(hackathon_id)}
	      </ul>
	    </div>

    ProjectsModel.register_callback(hackathon_id, function(_){
      #sortable = forum_render_projects(hackathon_id)
    })

	  View.forum(content)
  }

  /**
   * Called whenever the user reorders elements.
   *
   * This function updates the weight value on each project.
   */
  function void save_order(int hackathon_id) {
    // Read the new order
    nodes = Dom.select_raw_unsafe("#sortable > li")
    _ = Dom.fold(
      function (el, r) {
        id = Int.of_string(Dom.get_id(el))
        /prototype_forum/projects[id]/weight = r
        r+1
      },
      0,
      nodes
    )

    ProjectsModel.broadcast(hackathon_id)
    void
  }
}
