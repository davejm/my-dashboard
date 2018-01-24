require 'net/https'
require 'json'
require 'date'

# Forecast API Key from https://developer.forecast.io
forecast_api_key = ENV['DARKSKY_KEY']

#https://developers.google.com/maps/documentation/geocoding/intro
# Latitude, Longitude for location (Sheffield)
forecast_location_lat = "53.381129"
forecast_location_long = "-1.470085"

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
forecast_units = "uk"

SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  forecast = JSON.parse(response.body)

  today_weather = forecast['daily']['data'][0]
  today_temp_high = today_weather['temperatureHigh']
  today_temp_low = today_weather['temperatureLow']
  today_temp = ((today_temp_high + today_temp_low) / 2).round
  today_icon = today_weather['icon']
  today_summary = today_weather['summary']

  current_weather = forecast['currently']
  current_icon = current_weather['icon']
  current_temp = current_weather['temperature'].round

  # Return forecasts for the next 12 hours (API should return hourly for
  # 48 hours including current hour - we skip the current hour)
  nextHoursForecast = forecast['hourly']['data'][1..13]

  # Trim the data even more - only send what we need... be nice to AWS bills
  nextHoursForecast = nextHoursForecast.map do |hour|
    {
      hour: Time.at(hour['time']).hour,
      temperature: hour['temperature'].round,
      icon: hour['icon']
    }
  end

  nextHoursForecastObjectKeys = {}
  nextHoursForecast.each_with_index do |hour, i|
    nextHoursForecastObjectKeys[i] = hour
  end

  send_event('forecast', {
    today: {
      temperature: today_temp,
      icon: "#{today_icon}",
      summary: "#{today_summary}"
    },
    current: {
      temperature: current_temp,
      icon: "#{current_icon}",
    },
    nextHours: nextHoursForecast,
    nextHoursObjectKeys: nextHoursForecastObjectKeys
  })
end
