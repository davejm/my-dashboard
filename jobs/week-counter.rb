require 'date'

# Ordered array of Date range objects for term time (inclusive)
spring_semester_sections = [
  { # Weeks 1 - 7
    from: Date.new(2018, 2, 5),
    to: Date.new(2018, 3, 24)
  },
  { # Weeks 8 - 12
    from: Date.new(2018, 4, 16),
    to: Date.new(2018, 5, 20)
  }
]

# Makes a hashmap with key as date and value as the semester week num
def generate_week_lookup semester_sections
  week_lookup = {}
  week_num = 0

  semester_sections.each do |range|
    week_num += 1
    d = range[:from]
    last_cal_week_num = d.cweek
    while d <= range[:to]

      # If the calendar week num has changed then update the current calendar
      # week num and increase the semester week num
      if d.cweek != last_cal_week_num
        last_cal_week_num = d.cweek
        week_num += 1
      end

      week_lookup[d] = week_num

      d += 1
    end
  end

  week_lookup
end

# Precompute the date -> week lookup map
date_week_lookup = generate_week_lookup spring_semester_sections

def uni_week_number week_lookup
  t = Date.today
  # t = Date.new(2018, 4, 16) # DEBUG

  if week_lookup.keys.include? t
    return week_lookup[t]
  else
    return -1
  end
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  semester_week_number = uni_week_number(date_week_lookup)
  send_event('uni-week', { value: semester_week_number })
end
