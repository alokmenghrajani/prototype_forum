module Stats {
  function download_stats() {
    date_printer = Date.generate_printer("%m/%d/%Y")

    // Generate a table with the following info:
    // hackathon id, no projects, no contributors, no engineers, no interns
    data = IntMap.rev_fold(
      function(int id, hackathon h, string r) {
        stats1 = /prototype_forum/stats[id]
        stats2 = match (stats1.cache) {
          case {~some}: some
          case {none}: compute_stats(h.forum.projects)
        }
        s1 = "{h.name}\t{Date.to_formatted_string(date_printer, h.ts_start)}\t{IntMap.size(h.forum.projects)}\t"
        s2 = "{stats1.total_employees}\t{stats1.total_engineers}\t{stats1.total_interns}\t"
        s3 = "{stats2.n_employees}\t{stats2.n_engineers}\t{stats2.n_interns}"
        "{r}{s1}{s2}{s3}\n"
      },
      /prototype_forum/hackathons[],
      ""
    )
    csv = "Hackathon\tDate\tProjects\tTotal Employees\tTotal E\tTotal Interns\tEmployees\tE\tInterns\n{data}"
    r = Resource.raw_text(csv)
    Resource.add_header(r, {content_disposition: { attachment: "stats.tsv"}})
  }

  /**
   * Computes stats for every hackathon which is over and
   * caches the result.
   *
   * This data can be recomputed when needed by hitting /import
   *
   * TODO: recompute this data whenever the hackathon opens/closes.
   */
  function void compute_and_cache() {
    // find the list of hackathons we can cache.
    hackathons = IntMap.filter(function(_, h){not(HackathonModel.can_register(h))}, /prototype_forum/hackathons)

    _ = IntMap.mapi(
      function(int id, hackathon h) {
        stats = compute_stats(h.forum.projects)
        /prototype_forum/stats[id]/cache = {some: stats}
        void
      },
      hackathons
    )

    hackathons = IntMap.filter(function(_, h){HackathonModel.can_register(h)}, /prototype_forum/hackathons)
    _ = IntMap.mapi(
      function(int id, _) {
        /prototype_forum/stats[id]/cache = {none}
        void
      },
      hackathons
    )
    void
  }

  function stats() {
  	date_printer = Date.generate_printer("%_d %b %Y")

  	// Generate a table with the following info:
  	// hackathon id, no projects, no contributors, no engineers, no interns
  	list = IntMap.rev_fold(
      function(int id, hackathon h, r) {
        stats1 = /prototype_forum/stats[id]
        stats2 = match (stats1.cache) {
          case {~some}: some
          case {none}: compute_stats(h.forum.projects)
        }

        r <+>
          <tr>
          	<td><a href="hackathon/{id}">{h.name}
          	({Date.to_formatted_string(date_printer, h.ts_start)})</a></td>
          	<td>{IntMap.size(h.forum.projects)}</td>
          	<td>{stats1.total_employees}</td>
          	<td>{stats1.total_engineers}</td>
            <td>{stats1.total_interns}</td>
          	<td>{stats2.n_employees}</td>
          	<td>{stats2.n_engineers}</td>
          	<td>{stats2.n_interns}</td>
          </tr>
      },
      /prototype_forum/hackathons,
      <></>
    )

  	View.stats(
  	  <>
	  	  <div>
		  	  <table class="table table-bordered">
		        <tr>
		          <th>Hackathon</th>
		          <th>Projects</th>
		          <th>Total Employees</th>
		          <th>Total E</th>
              <th>Total Interns</th>
		          <th>Employees</th>
		          <th>E</th>
		          <th>Interns</th>
		        </tr>
		        {list}
		      </table>
		    </div>

	      <div><a href="/stats/download">Download data as CSV</a></div>
	    </>
	  )
  }

  function cacheable_data compute_stats(intset projects) {
  	// Compute the number of unique contributors
  	contributors = IntSet.fold(
  		function(id, intset contributors) {
  			project project = /prototype_forum/projects[id]
  			IntSet.union(project.contributors, contributors)
  		},
  		projects,
  		IntSet.empty
  	)

  	engineers = IntSet.fold(
  		function(int id, intset engineers) {
  			if (IntSet.mem(id, engineers)) {
  				// we already have this id
  				engineers;
  			} else if (/prototype_forum/people[id]/is_engineer) {
  				IntSet.add(id, engineers)
  			} else {
  				// no change
  				engineers;
  			}
  		},
  		contributors,
  		IntSet.empty
  	)

  	interns = IntSet.fold(
  		function(int id, intset interns) {
  			if (IntSet.mem(id, interns)) {
  				// we already have this id
  				interns;
  			} else if (/prototype_forum/people[id]/is_intern) {
  				IntSet.add(id, interns)
  			} else {
  				// no change
  				interns;
  			}
  		},
  		contributors,
  		IntSet.empty
  	)

  	{
  		n_employees: IntSet.size(contributors),
  		n_engineers: IntSet.size(engineers),
  		n_interns: IntSet.size(interns)
  	}
  }
}
