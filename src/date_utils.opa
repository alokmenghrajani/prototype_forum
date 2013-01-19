/**
 * Date related jonx
 */

module DateUtils {
  /**
   * Takes a Date.date and a desired Date.weekday.
   *
   * Advances Date.date to the next input weekday.
   *
   * e.g. advance_to_next_weekday(1/1/2013, 'monday') -> 7/1/2013
   *
   * If the input date is already the desired Date.weekday,
   * advances by 7 days.
   */
  function Date.date advance_to_next_weekday(Date.date date, Date.weekday weekday) {
    recursive function f(date) {
      if (Date.get_weekday(date) == weekday) {
        date
      } else {
        f(Date.advance(date, Duration.days(1)))
      }
    }
    if (Date.get_weekday(date) == weekday) {
      Date.advance(date, Duration.days(7))
    } else {
      f(date)
    }
  }

  /**
   * Set the hh/mm/ss in a Date.date object.
   */
  function Date.date set_time(Date.date date, int h, int m, int s) {
    midnight = Date.round_to_day(date)
    duration = Duration.add(Duration.h(h), Duration.min(m))
    duration = Duration.add(duration, Duration.s(s))
    Date.advance(midnight, duration)
  }
}