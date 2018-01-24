require 'open-uri'
require 'json'
require 'date'

BASE_URL = "https://api.coinbase.com/v2"

# Period should be one of 'hour', 'day', 'week', 'month', 'year', 'all'
def historical_prices(crypto, fiat, period)
  url = "#{BASE_URL}/prices/#{crypto}-#{fiat}/historic?period=#{period}"
  buffer = open(url).read
  decoded = JSON.parse(buffer)
  decoded['data']['prices']
end

# Parses iso8601 datetime to unix epoch
def parse_time(time)
  DateTime.iso8601(time).to_time.to_i
end

def points(prices)
  points = []
  prices.each do |tick|
    points.unshift({ x: parse_time(tick['time']), y: tick['price'].to_f })
  end
  points
end

# puts historical_prices('BTC', 'GBP', 'month')

SCHEDULER.every '1h', :first_in => 0 do |job|
  btc_gbp_points = points(historical_prices('BTC', 'GBP', 'month'))
  send_event('btc_gbp_graph',  points: btc_gbp_points )
end
