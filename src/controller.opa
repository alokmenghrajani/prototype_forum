module Controller {

  /**
   * TODO: there must be some easier way to get this info
   */
  public function UriUtils.uri getCurrentUri() {
    UriUtils.of_string("http://localhost:8080/")
  }

  public function check_do_login(UriUtils.uri uri) {
    match (UriUtils.getValue(uri, "__do_login")) {
      case {some: id}:
        UserModel.login(String.to_int(id))
        uri = UriUtils.removeKey(uri, "__do_login")
        {some: Resource.default_redirection_page(UriUtils.to_string(uri))}
      case {none}:
        {none}
    }
  }

  public function resource dispatcher(Uri.relative uri) {
    // Warning this is total clown town...

    current_uri = UriUtils.of_relative(uri)

    // Check if we got a __do_login parameter
    match (check_do_login(current_uri)) {
      case {~some}:
        some
      case {none}:
        require_login = match (uri) {
          case {path: ["logout"], ...}: false
          case {path: ["favicon.ico"], ...}: false // TODO: an opa bug?
          case {path: {hd:"presentation", tl:_}, ...}: false
          case {path: {hd:"files", tl:_}, ...}: false
          case {path: ["forum_status"], ...}: false
          case _: true
        }

        // uid = UserModel.get()
        // Utils.slog("{uid}: {Uri.to_string(Uri.of_relative(uri))} {require_login}")

        if (require_login && (UserModel.get() == 0)) {
          // TODO: finish this...
          Resource.raw_text("need to login")
        } else {
          match (Parser.try_parse(my_parser, Uri.to_string(Uri.of_relative(uri)))) {
            case {~some}: some
            case {none}: View.default_page("")
          }
        }
    }
  }

  // URL dispatcher of your application; add URL handling as needed
  my_parser = parser {
    case "/me": View.me()
    case "/hackathon/" id=([0-9]+): HackathonView.render(String.to_int(Text.to_string(id)), "")
    case "/hackathon/" id=([0-9]+) "?updated=": HackathonView.render(String.to_int(Text.to_string(id)), "Data updated successfully!")
    case "/hackathon/" id=([0-9]+) "?created=": HackathonView.render(String.to_int(Text.to_string(id)), "Project added successfully!")
    case "/hackathon/" id=([0-9]+) "?deleted=": HackathonView.render(String.to_int(Text.to_string(id)), "Project deleted successfully!")
    case "/stats/download": Stats.download_stats()
    case "/stats": Stats.stats()
    case "/admin": Admin.select()
    case "/admin/create": Admin.create()
    case "/admin/edit/" id=([0-9]+): Admin.update(String.to_int(Text.to_string(id)))
    case "/admin/delete/" id=([0-9]+): Admin.delete(String.to_int(Text.to_string(id)))
    case "/admin/tags": Admin.manage_tags()
    case "/register/" id=([0-9]+): Register.warning(String.to_int(Text.to_string(id)))
    case "/register/" id=([0-9]+) "?iknowwhatimdoing=": Register.create(String.to_int(Text.to_string(id)))
    case "/register/edit/" hack_id=([0-9]+) "/" id=([0-9]+):
      Register.update(String.to_int(Text.to_string(hack_id)), String.to_int(Text.to_string(id)))
    case "/register/delete/" hack_id=([0-9]+) "/" id=([0-9]+):
      Register.delete(String.to_int(Text.to_string(hack_id)), String.to_int(Text.to_string(id)))
    case "/?created=": View.default_page("New hackathon was successfully added!")
    case "/?deleted=": View.default_page("Hackathon was removed successfully!")
    case "/forum/" hack_id=([0-9]+): Forum.forum(String.to_int(Text.to_string(hack_id)))
    case "/presentation/" hack_id=([0-9]+): Presentation.present(String.to_int(Text.to_string(hack_id)))
    case "/files/" file_id=([a-h0-9]+): View.file(Text.to_string(file_id))
    case "/logout": View.logout()
    case "/favicon.ico": @static_resource("favicon.png")
    case "/forum_status": HackathonView.forum_status()
  }
}

resources = @static_resource_directory("resources")

Server.start(Server.http, [
  { register:
    [ { doctype: { html5 } },
      { js: [ ] },
      { css: [ "/resources/css/style.css"] }
    ]
  },
  { ~resources },
  { dispatch: Controller.dispatcher }
])

