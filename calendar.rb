require 'rubygems'
require 'google/api_client'

API_VERSION = 'v3'
CACHED_API_FILE = "calendar-#{API_VERSION}.cache"

client = Google::APIClient.new(
    :application_name => 'Ruby Calendar test Erik',
    :application_version => '0.0.1')

key = Google::APIClient::KeyUtils.load_from_pkcs12('client.p12', 'notasecret')
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/calendar',
  :issuer => '44935088495@developer.gserviceaccount.com',
  :signing_key => key)

client.authorization.fetch_access_token!

calendar = nil
if File.exists? CACHED_API_FILE
  File.open(CACHED_API_FILE) do |file|
    calendar = Marshal.load(file)
  end
else
  calendar = client.discovered_api('calendar', API_VERSION)
  File.open(CACHED_API_FILE, 'w') do |file|
    Marshal.dump(calendar, file)
  end
end

#calendars = client.execute(:api_method => calendar.calendar_list.list,
                           #:parameters => {:fields => 'items(id,summary)'})

#calendars.data.items.each {|cal| puts "#{cal.id} : #{cal.summary}" }

event = {
    'summary' => 'Ruby test',
    'start' => { 'dateTime' => DateTime.new(2014,3,5,13,0,0) }, #TODO: Blir en timme för sent!
    'end' => { 'dateTime' => DateTime.new(2014,3,5,14,0,0) },
    }

result = client.execute(:api_method => calendar.events.insert,
                        :parameters => {'calendarId' => 'q30c6nh1r41acel29qmefstss8@group.calendar.google.com'},
                        :body => JSON.dump(event),
                        :headers => {'Content-Type' => 'application/json'})