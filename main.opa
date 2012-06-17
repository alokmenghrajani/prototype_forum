/**
 * Prototype forum
 *
 * An open source tool to help manage prototype forums.
 * This tool will be super useful for people who organize
 * hackathons!
 *
 * Running: make run
 */

import stdlib.themes.bootstrap
import stdlib.web.client
import stdlib.database.db3

function resource display() {
  page =
    <div class="row">
      Registration page
    </div>

  Resource.styled_page(
    "Forum | registration",
    [],
    <>
      <div class="container">
        <div class="content">
          {page}
        </div>
      </div>
    </>
  )
}

function resource start(Uri.relative uri) {
  match (uri) {
    case {path:{nil} ...}:
      display()
    case {~path ...}:
//      my_log(path)
      Resource.styled_page("Lost?", [], <>* &lt;------- you are here</>)
  }
}

Server.start(
  Server.http,
  [
//    {resources: @static_include_directory("resources")},
    {dispatch: start}
  ]
)
