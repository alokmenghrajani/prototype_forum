/**
 * Code related to rendering of projects.
 *
 * The code here does not handle keeping things up-to-date. The higher layer
 * Views do that.
 */
module ProjectsView {
  public function list(xhtml) render_contributors_pics(project project) {
    List.rev(IntSet.fold(
      function(int uid, list(xhtml) r) {
        person = /prototype_forum/people[uid]
        List.cons(<img src={person.profile}/>, r)
      },
      project.contributors,
      []
    ))
  }

  public function render_tags(project p) {
    tags = IntSet.fold(
      function(int tag_id, list(xhtml) r) {
        if (IntMap.contains(tag_id, /prototype_forum/tags)) {
          tag = /prototype_forum/tags[tag_id]
          List.cons(<span class="tag label">{tag.name}</span>, r)
        } else {
          r;
        }
      },
      p.tags,
      []
    )
    <div class="tag-input">
      {tags}
    </div>
  }

  public function render_contributors_list(project project) {
    f = IntSet.fold(
      function(int uid, r) {
        person = /prototype_forum/people[uid]
        e = <a href="https://www.facebook.com/profile.php?id={uid}">{person.name}</a>
        match (r) {
          case {~some}:
            {some: some <+> <>&bull; {e}</>}
          case {none}:
            {some: e}
        }
      },
      project.contributors,
      {none}
    )
    match (f) {
      case {~some}: some
      case {none}: <></>
    }
  }

  public function xhtml render_links(project project) {
    f = List.map(
      function ((string, string) e) {
        <li><a href="{e.f2}" target="_blank">{e.f1}</a></li>
      },
      project.links
    )
    <ul>{f}</ul>
  }
}