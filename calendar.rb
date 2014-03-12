# Load the bundled environment
require 'rubygems'
require "bundler/setup"

# Require gems specified in the Gemfile
require 'google/api_client'
require 'date'

times = "10,00-18,30
10,00-17,00
8,30-19,15
LED
11,00-19,15
LED
LED
"

if ARGV.length == 0
    puts "Usage: blablabal"
    exit 1
end

weekno = ARGV[0]

API_VERSION = 'v3'
CACHED_API_FILE = "calendar-#{API_VERSION}.cache"

@client = Google::APIClient.new(
    :application_name => 'Ruby Calendar test Erik',
    :application_version => '0.0.1')

key = Google::APIClient::KeyUtils.load_from_pkcs12('client.p12', 'notasecret')
@client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/calendar',
  :issuer => '44935088495@developer.gserviceaccount.com',
  :signing_key => key)

@client.authorization.fetch_access_token!

@calendar = nil
if File.exists? CACHED_API_FILE
  File.open(CACHED_API_FILE) do |file|
    @calendar = Marshal.load(file)
  end
else
  @calendar = @client.discovered_api('calendar', API_VERSION)
  File.open(CACHED_API_FILE, 'w') do |file|
    Marshal.dump(@calendar, file)
  end
end

@calendars = {:anna => "pq5e7ok2c5njqok5opevqnd1qg@group.calendar.google.com",
             :agust => "4n598otsb91q7ulm2mic242v9k@group.calendar.google.com",
             :erik => "q30c6nh1r41acel29qmefstss8@group.calendar.google.com"}

#calendars = client.execute(:api_method => calendar.calendar_list.list,
#                           :parameters => {:fields => 'items(id,summary)'})

#calendars.data.items.each {|cal| puts "#{cal.id} : #{cal.summary}" }


def getTime(week, day, time)
    DateTime.parse("W#{week}-#{day} #{time.gsub(',',':')}+1").to_time
end

def getTimesArray(weekno, hours)
    hours.split(%r{\n}).map.with_index { |day, i|
        if !day.nil? && day != "LED" && !day.empty?
            times = day.split("-")
            [getTime(weekno, i+1, times[0]), getTime(weekno, i+1, times[1])]
        end
    }.compact
end

class Workday
    attr_accessor :from, :to
    
    def initialize(f=nil, t=nil)
        @from, @to = f, t        
    end
    
    def to_s
        "#{@from.strftime '%H:%M'} - #{@to.strftime '%H:%M'}"
    end
end

class Daycare < Workday
    attr_accessor :leave, :pickup
    
    def to_s
        "#{leave} - #{pickup}"
    end
end

def createEvent(cal, workday)    
    event = {
        'summary' => workday,
        'start' => { 'dateTime' => workday.from.to_datetime },
        'end' => { 'dateTime' => workday.to.to_datetime },
        }

    @client.execute(:api_method => @calendar.events.insert,
        :parameters => {'calendarId' => cal},
        :body => JSON.dump(event),
        :headers => {'Content-Type' => 'application/json'})    
end

getTimesArray(weekno, times).each do |day|
    anna = Workday.new day[0], day[1]        
    
    if !((1..5) === anna.from.wday)        
        createEvent(calendars[:anna], anna)
        break
    end
    
    erik = Workday.new(
        Time.new(anna.from.year, anna.from.month, anna.from.day, 7, 30),
        Time.new(anna.from.year, anna.from.month, anna.from.day, 16, 0))
    
    agust = Daycare.new
    
    if anna.from > erik.from
        agust.leave = "Anna"
        agust.from = anna.from - 1800 # 30 min tidigare
    else
        agust.leave = "Erik"
        agust.from = erik.from - 1800 # 30 min tidigare
    end
    
    if anna.from.monday?
        agust.to = Time.new(anna.from.year, anna.from.month, anna.from.day, 14, 0)

        if weekno.to_i.odd?
            agust.pickup = "Eva & Alf"
        else
            agust.pickup = "Karin & Anders"
        end
    else
        if anna.to > erik.to
            agust.pickup = "Erik"
            erik.to = Time.new(anna.from.year, anna.from.month, anna.from.day, 15, 0)
            agust.to = erik.to + 1800
        else
            agust.pickup = "Anna"
            if anna.to > Time.new(anna.from.year, anna.from.month, anna.from.day, 13, 30)
                agust.to = anna.to + 1800
            else
                agust.to = Time.new(anna.from.year, anna.from.month, anna.from.day, 14, 0)
            end
        end
    end

    createEvent(@calendars[:anna], anna)
    createEvent(@calendars[:erik], erik)
    createEvent(@calendars[:agust], agust)
end