/**
 * This module is responsible for the presentation mode.
 */
module Presentation {
	function present(int hackathon_id) {
    project_id = /prototype_forum/selected[hackathon_id]

    content =
      <>
        <style>{"html, body \{ height: 100%; overflow: hidden \}"}</style>
        {gen_content(hackathon_id, project_id)}
      </>

    /**
     * Called when the content of project changes or when a hackathon gets updated.
     */
    ProjectsModel.register_callback(
      hackathon_id,
      function(_) {
        Window.close_all()
        selected_id = /prototype_forum/selected[hackathon_id]
        #presentation = gen_content(hackathon_id, selected_id)
      }
    )

		Resource.page("Prototype Forum", content)
	}

  function xhtml gen_content(int hackathon_id, int project_id) {
    hackathon = /prototype_forum/hackathons[hackathon_id]
    project = /prototype_forum/projects[project_id]

    date_printer = Date.generate_printer("%_d %b %Y")

    <div id=#presentation class="hack_forum">
      <div class="border">
        <p class="facebook-title">Prototype Forum</p>
        <div class="b">
          <div class="date-title">{hackathon.name}</div>
          <div class="date-subtitle">
            {Date.to_formatted_string(date_printer, hackathon.forum.ts_start)}
          </div>
        </div>
      </div>
      <div id="project">
        <p class="pres-title">
          {project.title}
        </p>
        <p class="pres-subtitle">
          <span style="color: #7d97c2">By: </span>
          {render_contributors_list(project.contributors)}
          {render_links(project.links)}
        </p>
      </div>
    </div>
  }

  function xhtml render_links(list((string, string)) links) {
    f = List.fold(
      function ((string, string) e, r) {
        <>
          {r}
          <li><a onclick={function(_){Window.open(e.f2, e.f1)}}>{e.f1}</a></li>
        </>
      }
      ,
      links,
      <></>
    )
    <ul>{f}</ul>
  }

	function xhtml render_contributors_list(intset contributors) {
    f = IntSet.fold(
      function(int uid, r) {
        person = /prototype_forum/people[uid]
        e = <>{person.name}</>
        match (r) {
          case {~some}:
            {some: <>{some}, {e}</>}
          case {none}:
            {some: e}
        }
      },
      contributors,
      {none}
    )
    match (f) {
      case {~some}: some
      case {none}: <></>
    }
  }
}

