/**
 * User/login related code.
 */
module UserModel {
  private UserContext.t(option(int)) logged_user = UserContext.make({none})

  /**
   * For debugging purpose
   */
  public function void logout() {
    UserContext.set(logged_user, {none})
  }

  // TODO: convert this to use Connect
  public function void login(int uid) {
    UserContext.set(logged_user, {some: uid})
  }

  public function int get() {
    match (UserContext.get(logged_user)) {
      case {~some}:
        some
      case {none}:
        0
    }
  }

  /**
   * TODO: build an interface to manage the admins
   */
  public function is_admin(int uid) {
    admins = [
      536181839  /* alok */,
    ]
    List.contains(uid, admins)
  }
}
