/**
 * A little widget to pick a date & time
 */

module WDateTimePicker {
	public function xhtml html(string dom_id, Date.date initial) {
		time_printer = Date.generate_printer("%H:%M")

		<>
		  {WDatepicker.edit_default(function(_){void}, "date_{dom_id}", initial)}
		  <input type="text" id="time_{dom_id}" class="input" placeholder="hh:mm"
  		  value={Date.to_formatted_string(time_printer, initial)}>
		</>
	}

	public function option(Date.date) get(string dom_id) {
		match (WDatepicker.parse_default("date_{dom_id}")) {
			case {none}:
				// we failed to get a valid date
				{none}
			case {some: date}:
				// try to parse the time
				p = Date.generate_scanner("%H:%M")
				match (Date.of_formatted_string(p, Dom.get_value(Dom.select_id("time_{dom_id}")))) {
					case {none}:
						// we failed to get a valid time
						{none}
					case {some: time}:
						// Add the date and time
						{some: Date.advance(date, Duration.of_date(time))}
				}
		}
	}
}
