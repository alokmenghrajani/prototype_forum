/**
 * Used to create, update or modify a hackathon.
 */
module HackathonModel {
  private Network.network(void) hackathons_change = Network.cloud("hackathons")

  /**
   * Adds a hackathon
   */
  public function void create(hackathon data) {
    hackathon_id = Model.gen_next_id()
    update(hackathon_id, data)
  }

  /**
   * Updates a hackathon
   */
  public function void update(int hackathon_id, hackathon data) {
    /prototype_forum/hackathons[hackathon_id] <- data

    Network.broadcast(void, hackathons_change)
    ProjectsModel.broadcast(hackathon_id)
  }

  /**
   * Very clowny
   */
  public function void broadcast(int hackathon_id) {
  	ProjectsModel.broadcast(hackathon_id)
  }

  /**
   * Removes a hackathon
   *
   * Note: by designing, the code does not handle the case where
   *       people are trying to register a project and we delete
   *       the hackathon. I don't think this will happen often
   *       enough that we need to care...
   */
  public function void delete(int hackathon_id) {
  	Db.remove(@/prototype_forum/hackathons[hackathon_id])

  	Network.broadcast(void, hackathons_change)
  }

  /**
   * Registers a callback.
   *
   * Called whenever a hackathon is added, updated or deleted.
   */
  public function void register_callback(callback) {
    Network.add_callback(function(_){callback()}, hackathons_change)
  }

  /**
   * Helper function to check if registration is open for a given
   * hackathon.
   */
  public function bool can_register(hackathon hackathon) {
  	if (not_yet_open(hackathon)) {
  		// Registration is still closed
  	  false;
  	} else if (hackathon.forum.ts_start < Date.now()) {
  	  // This Hackathon is over
  	  false;
  	} else {
  		// Registration is open
      true;
  	}
  }

  public function bool not_yet_open(hackathon hackathon) {
  	// TODO: improve this by using an option(Date.date)
  	hackathon.forum.ts_start == Date.milliseconds(0)
  }
}
