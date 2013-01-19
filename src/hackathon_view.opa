/**
 * Used to render info related to hackathons.
 *
 * E.g. list of hackathons on various views.
 */
module HackathonView {
	/**
	 * Renders the main hackathon view.
   * e.g. http://localhost:8080/hackathon/35
   */
	public function render(int hackathon_id, string dlg) {
		content = <div id=#hackathon>
			{do_render(hackathon_id)}
		</div>

    ProjectsModel.register_callback(hackathon_id,
    	function(_){#hackathon=do_render(hackathon_id)})

    View.page_template("Prototype Forum", content, dlg)
	}

	private function do_render(int hackathon_id) {
		hackathon = /prototype_forum/hackathons[hackathon_id]
		date_printer = Date.generate_printer("%_d %b %Y")

		project_registration = if (HackathonModel.not_yet_open(hackathon)) {
			<section id="forum">
        <div class="page-header">
          <h1>Prototype Forum</h1>
        </div>
        <p>The Prototype Forum has not yet been scheduled. Registration will open soon.</p>
      </section>
		} else if (HackathonModel.can_register(hackathon)) {
			<section id="forum">
        <div class="page-header">
          <h1>Prototype Forum</h1>
        </div>
        <p>Date: {Date.to_formatted_string(Date.default_printer, hackathon.forum.ts_start)}</p>
        <p>Info/location: {hackathon.forum.info}</p>
        <a href="/register/{hackathon_id}" class="btn btn-primary btn-small">Register your Hack »</a>
      </section>
		} else {
			<></>
		}

		admin_edit = if (UserModel.is_admin(UserModel.get())) {
			<small>
				<a href="/admin/edit/{hackathon_id}">edit</a>
        | <a href="/admin/delete/{hackathon_id}">delete</a>
      </small>
		} else {
			<></>
		}

    <>
      <div class="hero-unit">
        <h1>{hackathon.name} {admin_edit}</h1>
        <p>{Date.to_formatted_string(date_printer, hackathon.ts_start)}</p>
        <p><a href="{hackathon.url}">{hackathon.url}</a></p>
      </div>
      {project_registration}
      <section>
        {render_projects(hackathon_id, hackathon)}
      </section>
    </>
	}

	private function render_projects(int hackathon_id, hackathon hackathon) {
    n = IntMap.size(hackathon.forum.projects)
    s_projects =
      if (n == 0) {
        "There are currently no projects";
      } else if (n == 1) {
        "1 Project";
      } else {
        "{n} Projects";
      }

    <>
      <div class="page-header">
        <h1>{s_projects}</h1>
      </div>
      {render_projects_list(hackathon_id)}
    </>
	}

	private function list(xhtml) render_projects_list(int hackathon_id) {
		sorted_and_grouped_projects = ProjectsModel.get(hackathon_id)
		locations = Model.get_locations()

		List.map(
			function(location) {
			  <>
			  	{Model.location_to_xhtml(location)}
			  	{render_projects_for_location(hackathon_id, location, sorted_and_grouped_projects)}
			  </>
			},
			locations
		)
	}

	private function list(xhtml) render_projects_for_location(int hackathon_id, location location, sorted_and_grouped_projects) {
		projects = Option.default([], Map.get(location, sorted_and_grouped_projects))

		List.map(
      function (project) {
        int id = project.id
        project p = project.project

        edit = if (IntSet.mem(UserModel.get(), p.contributors) ||
                   UserModel.is_admin(UserModel.get())) {
          <div class="close">
            <a href="/register/edit/{hackathon_id}/{id}">edit</a>
            | <a href="/register/delete/{hackathon_id}/{id}">delete</a>
          </div>
        } else {
          <></>
        }

        <div class="well">
          {ProjectsView.render_contributors_pics(p)}
          {edit}
          <h3>{p.title}
            <small>By: {ProjectsView.render_contributors_list(p)}</small>
          </h3>
          <small>{ProjectsView.render_tags(p)}</small>
          <h4>Planned</h4>
          <p>{p.planned}</p>
          <h4>Achieved</h4>
          <p>{p.achieved}</p>
          <p>{ProjectsView.render_links(p)}</p>
        </div>
      },
      projects
    )
  }

	/**
	 * Renders a list of hackathons which gets updated if a hackathon changes name.
	 *
	 * callback is used to render the actual link.
	 */
	public function render_list((int -> string) render_link) {
		content = do_render_list(render_link)

		HackathonModel.register_callback(function() {
			#hackathon_list = do_render_list(render_link)
		})

    <ul id=#hackathon_list class="nav nav-list">
			{content}
		</ul>
	}

	public function render_current_and_past((int -> string) render_link) {
		content = do_render_current_and_past(render_link)

		HackathonModel.register_callback(function() {
			#hackathon_list = do_render_current_and_past(render_link)
		})

		<div id=#hackathon_list>
		  {content}
		</div>
	}

	private function render_entry(int hackathon_id, hackathon hackathon, render_link) {
		date_printer = Date.generate_printer("%_d %b %Y")

    <li>
      <a href="{render_link(hackathon_id)}">
        <i class="icon-chevron-right"/>
        {hackathon.name} ({Date.to_formatted_string(date_printer, hackathon.ts_start)})
      </a>
    </li>
	}

	private function list(xhtml) do_render_list(render_link) {
		IntMap.fold(
  	  function(int hackathon_id, hackathon hackathon, list(xhtml) r) {
        List.cons(render_entry(hackathon_id, hackathon, render_link), r)
      },
      /prototype_forum/hackathons,
      []
    )
	}

  /**
   * Returns a string telling us if a forum is +/- happening right now.
   *
   * Useful for external tools.
   */
  public function forum_status() {
    hackathons = /prototype_forum/hackathons

    registration_open = IntMap.filter(function(_, h) {

      ts_end = Date.advance(h.forum.ts_start, Duration.h(4))          // 4h since forum's last usually <2h
      ts_start = Date.shift_backward(h.forum.ts_start, Duration.h(2)) // 2h before for testing purpose
      ts_now = Date.now()

      (ts_start < ts_now) && (ts_now < ts_end)
    }, hackathons)
    if (IntMap.is_empty(registration_open)) {
      Resource.raw_text("closed");
    } else {
      Resource.raw_text("open");
    }
  }

	private function do_render_current_and_past(render_link) {
		hackathons = /prototype_forum/hackathons

    registration_open = IntMap.filter(function(_, h){HackathonModel.can_register(h)}, hackathons)
		content_open = if (IntMap.is_empty(registration_open)) {
			[<>Prototype forum registration is currently closed. Please come back later.</>]
		} else {
			IntMap.fold(
				function (int hackathon_id, hackathon hackathon, list(xhtml) r) {
					List.cons(render_entry(hackathon_id, hackathon, render_link), r)
				},
				registration_open,
				[]
			)
		}

		registration_closed = IntMap.filter(function(_, h){not(HackathonModel.can_register(h))}, hackathons)
		content_closed = IntMap.fold(
			function (int hackathon_id, hackathon hackathon, list(xhtml) r) {
				List.cons(render_entry(hackathon_id, hackathon, render_link), r)
			},
			registration_closed,
			[]
		)

		<>
			<section id="current-hackathons">
	      <div class="page-header">
	        <h1>Current Hackathons</h1>
	      </div>
	      <ul class="nav nav-list">
	        {content_open}
	      </ul>
	    </section>
			<section id="past-hackathons">
	      <div class="page-header">
	        <h1>Other Hackathons</h1>
	      </div>
	      <ul class="nav nav-list">
	        {content_closed}
	      </ul>
	    </section>
	  </>
	}
}
