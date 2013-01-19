type hackathon =
  {
    string name,
    string url,
    Date.date ts_start,
    Date.date ts_end,
    forum forum,
  }

type forum =
  {
    Date.date ts_start,
    string info,
    intset projects,
  }

type location =
  { newyork } or
  { seattle } or
  { london } or
  { mpk_projector } or
  { mpk_shared } or
  { mpk_laptop }

type project =
  {
  	string title,
   	string planned,
  	string achieved,
  	int audit,
  	location location,
  	intset contributors,
  	list((string, string)) links, // (title, url) pairs
  	bool flagged,
    int weight, // used for ordering purpose
    intset tags,
  }

type tag =
  {
    string name
  }

type person =
  {
  	string name,
  	string unixname,
  	string profile,
  	Date.date start_date,
  	string tshirt,
  	bool is_engineer,
  	bool is_intern,
  }

type file =
  {
    string filename,
    string mimetype,
    binary data,
  }

type employee_tag =
  {
  	int uid,
  	string name,
  	string unixname
  }

type stat =
  {
    bool is_engineer,
    bool is_intern
  }

type cacheable_data =
  {
    int n_employees,
    int n_engineers,
    int n_interns,
  }

type hackathon_stat =
  {
    intmap(stat) contributors,
    int total_employees,
    int total_engineers,
    int total_interns,
    option(cacheable_data) cache,
  }

type employee_tag_set = list(employee_tag)

database prototype_forum {
  int /next_id = 0

  intmap(hackathon) /hackathons

  intmap(person)    /people

  intmap(project)   /projects
  /projects[_]/location = { mpk_laptop }
  /projects[_]/flagged = false

  /people[_]/is_engineer = false
  /people[_]/is_intern = false


  stringmap(file) /files

  // Facebook specific
  // Opa sucks at quickly accessing data from the DB layer,
  // so we keep things as a json string.
  string /employee_tags

  // Used to manage the forums
  intmap(int) /selected

  intmap(tag) /tags

  intmap(hackathon_stat) /stats // Keep stats on a per hackathon, per contributor basis
  /stats[_]/contributors[_]/is_engineer = false
  /stats[_]/contributors[_]/is_intern = false
}

module Model {

  public function int gen_next_id() {
    // TODO: this needs to race condition free
    next_id = /prototype_forum/next_id + 1
    /prototype_forum/next_id <- next_id
    next_id
  }


  protected function list(employee_tag) get_employee_tags() {
	  OpaSerialize.unserialize_unsafe(/prototype_forum/employee_tags, @typeval(employee_tag_set))
  }

  /**
   * A callback that gets called whenever any piece of data changes.
   *
   * Useful for the stats engine, as well as the quickly hacked together /me page.
   */
  function void register_universal_callback(callback) {
    HackathonModel.register_callback(callback)
    ProjectsModel.register_universal_callback(callback)
  }

  public function list(location) get_locations() {
    // TODO: nicer way to write this?
    [{london}, {newyork}, {seattle}, {mpk_projector}, {mpk_shared}, {mpk_laptop}]
  }

  public function location string_to_location(string l) {
    match (l) {
      case "london": {london}
      case "newyork": {newyork}
      case "seattle": {seattle}
      case "mpk_projector": {mpk_projector}
      case "mpk_shared": {mpk_shared}
      case "mpk_laptop": {mpk_laptop}
      case _: {mpk_laptop}
    }
  }

  public function string location_to_string(location l) {
    match (l) {
      case {london}: "london"
      case {newyork}: "newyork"
      case {seattle}: "seattle"
      case {mpk_projector}: "mpk_projector"
      case {mpk_shared}: "mpk_shared"
      case {mpk_laptop}: "mpk_laptop"
    }
  }

  public function xhtml location_to_xhtml(location l) {
     match (l) {
      case {london}: <h3>London</h3>
      case {newyork}: <h3>New York</h3>
      case {seattle}: <h3>Seattle</h3>
      case {mpk_projector}: <h3>Menlo Park - projector</h3>
      case {mpk_shared}: <h3>Menlo Park - shared laptop</h3>
      case {mpk_laptop}: <h3>Menlo Park - bring you own laptop</h3>
    }
  }
}
