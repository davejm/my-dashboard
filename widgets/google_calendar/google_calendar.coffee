class Dashing.GoogleCalendar extends Dashing.Widget

  onData: (data) =>
    first_event = rest = null
    getEvents = (first, others...) ->
      first_event = first
      rest = others

    getEvents data.events...

    start = moment(first_event.start)
    end = moment(first_event.end)

    @set('first_event', first_event)
    @set('first_event_date', start.format('dddd Do MMMM'))
    @set('first_event_times', start.format('HH:mm') + " - " + end.format('HH:mm'))

    next_events = []
    for next_event in rest
      start = moment(next_event.start)
      end   = moment(next_event.end)
      start_time = start.format('HH:mm')
      end_time   = end.format('HH:mm')

      next_events.push { summary: next_event.summary, start_time: start_time, end_time: end_time }
    @set('next_events', next_events)
