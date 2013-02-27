require 'active_support/core_ext'
require 'google/api_client'
require 'yaml'

oauth_yaml = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))
client = Google::APIClient.new
client.authorization.client_id = oauth_yaml['calendar']['client_id']
client.authorization.client_secret = oauth_yaml['calendar']['client_secret']
client.authorization.scope = oauth_yaml['calendar']['scope']
client.authorization.refresh_token = oauth_yaml['calendar']['refresh_token']
client.authorization.access_token = oauth_yaml['calendar']['access_token']

if client.authorization.refresh_token && client.authorization.expired?
  client.authorization.fetch_access_token!
end

service = client.discovered_api('calendar', 'v3')

SCHEDULER.every '15m', :first_in => 0 do |job|
  result = client.execute(:api_method => service.events.list, :parameters => {
    'calendarId' => 'primary',
    'orderBy' => 'startTime',
    'singleEvents' => true,
    'timeMin' => Time.now.strftime('%FT%T.%LZ')
  })

  data = {}
  first = result.data.items.first
  first_date = (first.start['date'] or first.start['dateTime']).to_datetime
  if first_date.to_date == Date.today
    data['today'] = {
      'summary' => first.summary,
      'start' => first_date.strftime('%H:%M')
    }
  else
    data['today'] = nil
  end

  data['events'] = []
  start = data['today'].nil? ? 0 : 1
  result.data.items[start..-1].each do |event|
    date = (event.start['date'] or event.start['dateTime']).to_datetime
    data['events'].push({
      'summary' => event.summary,
      'start' => date.strftime('%d.%m %H:%M')
    })
  end

  send_event('calendar', data)
end
