module View {

  function import() {
    // Import the list of hackathons and other pieces of data...
    page_template("Import", <>Done importing data</>, "")
  }

  function page_template(title, content, dlg) {

    dialog = if (dlg != "") {
      <div class="alert alert-success">{dlg}</div>
    } else {
      <></>
    }

    admin_nav = if (UserModel.is_admin(UserModel.get())) {
      <li><a href="/admin" style="color: white; text-shadow: none">Admin</a></li>
      <li><a href="/stats" style="color: white; text-shadow: none">Stats</a></li>
    } else {
      <></>
    }


    html =
      <div class="fbnav navbar navbar-fixed-top">
        <div class="navbar-inner">
          <div class="container">
            <a class="brand" style="color: white; text-shadow: none" href="/">Prototype Forum</>
            <div class="nav-collapse collapse">
              <ul class="nav">
                {admin_nav}
                <li><a href="/me" style="color: white; text-shadow: none" >Profile</a></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <div id=#main class="container">
        {dialog}
        {content}
      </div>
      <footer class="footer">
        <div class="container">
        </div>
      </footer>
    Resource.page(title, html)
  }

  function default_page(string dlg) {
    render_link = function(hackathon_id) {
      "/hackathon/{hackathon_id}"
    }

    content =
      <>
        <div class="hero-unit">
          <h1>Welcome!</h1>
          <p>
            This tool lets you look at what people built in the past and register your Hack. It
            also provides an interface to manage the Prototype Forum event and visualize some basic statistics.
          </p>
        </div>
        {HackathonView.render_current_and_past(render_link)}
      </>

    page_template("Prototype Forum", content, dlg)
  }

  function stats(xhtml content) {
    page_template("Prototype Forum | Stats", content, "")
  }

  function admin(xhtml content) {
    page_template("Prototype Forum | Admin", content, "")
  }

  function warning(xhtml content) {
    page_template("Prototype Forum | Sign up", content, "")
  }

  function register(xhtml content) {
    page_template("Prototype Forum | Sign up", content, "")
  }

  function forum(xhtml content) {
    page_template("Prototype Forum | Forum", content, "")
  }

  function presentation(xhtml content) {
    page_template("Prototype Forum | Presentation", content, "")
  }

  /**
   * Useful for debugging purpose.
   */
  function logout() {
    UserModel.logout()
    Resource.default_redirection_page("http://www.perdu.com/")
  }

  function me() {
    int uid = UserModel.get()
    person p = /prototype_forum/people[uid]

    content =
      <>
        <h2>{p.name}'s profile</h2>
        <p>Tshirt size: {p.tshirt}</p>

        <div id=#hacks>
          {render_hacks(uid)}
        </div>
      </>

    // sad-panda :(
    Model.register_universal_callback(function(){
      #hacks = render_hacks(uid)
    })

    page_template("Prototype Forum | Me", content, "")
  }

  function file(string file_id) {
    data = /prototype_forum/files[file_id]

    Resource.binary(data.data, data.mimetype)
  }

  /**
   * Returns hackathons with only the projects where uid participated.
   */
  private function get_hackathons(int uid) {
    // first filter projects
    hackathons = IntMap.map(
      function(hackathon hackathon) {
        f = {hackathon.forum with projects: IntSet.filter(
          function (int project_id) {
            IntSet.mem(uid, /prototype_forum/projects[project_id]/contributors)
          }, hackathon.forum.projects)}
        {hackathon with forum: f}
      },
      /prototype_forum/hackathons
    )

    // filter out hackathons where these are no projects
    IntMap.filter(
      function (_, hackathon hackathon) {
        not(IntSet.is_empty(hackathon.forum.projects))
      },
      hackathons
    )
  }

  private function list(xhtml) render_hacks(int uid) {
    date_printer = Date.generate_printer("%_d %b %Y")

    hackathons = get_hackathons(uid)

    IntMap.fold(
      function(int hackathon_id, hackathon hackathon, list(xhtml) r) {
        List.cons(
          <>
            <h3><a href="/hackathon/{hackathon_id}">{hackathon.name}</a> (
              {Date.to_formatted_string(date_printer, hackathon.ts_start)})</h3>
            {do_render_hacks(hackathon_id, hackathon)}
          </>,
          r)

      },
      hackathons,
      []
    )
  }

  private function list(xhtml) do_render_hacks(int hackathon_id, hackathon hackathon) {
    IntSet.fold(
      function(int project_id, list(xhtml) r) {
        project = /prototype_forum/projects[project_id]

        List.cons(
          <div class="well">
            {ProjectsView.render_contributors_pics(project)}
            <div class="close">
              <a href="/register/edit/{hackathon_id}/{project_id}">edit</a>
              | <a href="/register/delete/{hackathon_id}/{project_id}">delete</a>
            </div>
            <h3>{project.title}
              <small>By: {ProjectsView.render_contributors_list(project)}</small>
            </h3>
            <h4>Planned</h4>
            <p>{project.planned}</p>
            <h4>Achieved</h4>
            <p>{project.achieved}</p>
            <p>{ProjectsView.render_links(project)}</p>
          </div>,
          r)
      },
      hackathon.forum.projects,
      []
    )
  }
}
