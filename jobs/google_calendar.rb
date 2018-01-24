require 'icalendar'

ical_url = ENV['ICAL_URL']
uri = URI ical_url

TODAY = Date.today
# TODAY = Date.new(2018,3,1) # TESTING

SCHEDULER.every '30m', :first_in => 0 do |job|
  result = Net::HTTP.get uri
  calendars = Icalendar::Calendar.parse(result)
  calendar = calendars.first

  events = calendar.events.map do |event|
    {
      start: event.dtstart,
      end: event.dtend,
      summary: event.summary
    }
end.select { |event| event[:start].to_date == TODAY }

  events = events.sort { |a, b| a[:start] <=> b[:start] }

  # events = events[0..5]

  send_event('google_calendar', { events: events })
end
