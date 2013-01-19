/**
 * Code related to manipulating the projects data model.
 */
module ProjectsModel {
  // TODO: we could improve this network by broadcasting different messages for
  // adding a project to a list, updating a project or removing a project.
  private Network.network(int) projects_change = Network.cloud("projects") // hackathon_id

  /**
   * Sets the selected project.
   */
  public function update_selected(int hackathon_id, int project) {
    /prototype_forum/selected[hackathon_id] <- project
    Network.broadcast(hackathon_id, projects_change)
  }

  /**
   * Adds a project to the various database locations.
   */
  public exposed function create(int hackathon_id, project data) {
    project_id = Model.gen_next_id()
    update(hackathon_id, project_id, data)
  }

  /**
   * Updates the data related to a project.
   */
  public exposed function update(int hackathon_id, int project_id, project data) {
    /prototype_forum/projects[project_id] <- data

    // TODO: wrap this in a transaction
    set = IntSet.add(project_id, /prototype_forum/hackathons[hackathon_id]/forum/projects)
    /prototype_forum/hackathons[hackathon_id]/forum/projects <- set

    Network.broadcast(hackathon_id, projects_change)
    HackathonModel.broadcast(hackathon_id)
  }

  /**
   * Used to broadcast random changes, which are not related to a specific project.
   */
  public function broadcast(int hackathon_id) {
    Network.broadcast(hackathon_id, projects_change)
  }

  /**
   * Deletes a project.
   *
   * This ia soft delete. The project data continues to exist, but we remove it
   * from the list of projects for a given hackathon. In theory, we could expose an undelete
   * options.
   */
  public function delete(int hackathon_id, int project_id) {
    // TODO: wrap this in a transaction
    set = /prototype_forum/hackathons[hackathon_id]/forum/projects
    /prototype_forum/hackathons[hackathon_id]/forum/projects <- IntSet.remove(project_id, set)

    Network.broadcast(hackathon_id, projects_change)
  }

  /**
   * Registers a callback, which will get called whenever a project is added, updated or deleted.
   */
  public function void register_callback(int hackathon_id, callback) {
    Network.add_callback(function(x){if (x == hackathon_id) { callback(x) }}, projects_change)
  }

  public function void register_universal_callback(callback) {
    Network.add_callback(function(_){callback()}, projects_change)
  }

  /**
   * Returns all the projects in a given hackathon, sorted
   * according to their locations and weights.
   *
   * Return structure is:
   * map of location => list of {id: project_id, project: project}
   */
  function get(int hackathon_id) {
    projects = /prototype_forum/hackathons[hackathon_id]/forum/projects

    // Group projects by location
    grouped_by_location = IntSet.fold(
      function(project_id, r) {
        project = /prototype_forum/projects[project_id]
        l = Option.default([], Map.get(project.location, r))
        l = List.cons({id: project_id, project: project}, l)
        Map.add(project.location, l, r)
      },
      projects,
      Map.empty
    )

    // For each group, sort the list by weight
    Map.map(
      function(l) { List.sort_by(function(e){e.project.weight}, l) },
      grouped_by_location
    )
  }
}