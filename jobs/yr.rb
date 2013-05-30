require 'nokogiri'
require 'open-uri'
require 'yaml'

YR_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

SCHEDULER.every '15m', :first_in => 0 do |job|
  doc = Nokogiri::XML(open(YR_CONFIG['yr']['url']))
  tabular = doc.xpath('/weatherdata/forecast/tabular/time[1]')
  weatherStation = doc.xpath('/weatherdata/observations/weatherstation[1]')
  windSpeed = weatherStation.xpath('windSpeed')
  data = {
    'location' => doc.xpath('/weatherdata/location/name').text,
    'from' => tabular.attr('from').value,
    'to' => tabular.attr('to').value,
    'temperature' => weatherStation.xpath('temperature').attr('value').value,
    'description' => tabular.xpath('symbol').attr('name').value,
    'wind' => {
      'speed' => windSpeed.attr('mps').value,
      'description' => windSpeed.attr('name').value,
      'direction' => weatherStation.xpath('windDirection').attr('name').value
    }
  }
  send_event('yr', data)
end
