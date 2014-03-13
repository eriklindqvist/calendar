#encoding: utf-8

# Load the bundled environment
require 'rubygems'
require "bundler/setup"

# Require gems specified in the Gemfile
require 'google/api_client'
require 'date'

times = "9,00-18,30
9,00-13,00
LED
11,00-19,15
12,00-19,15
10,00-16,15
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

$calendars = {:anna => "pq5e7ok2c5njqok5opevqnd1qg@group.calendar.google.com",
             :agust => "4n598otsb91q7ulm2mic242v9k@group.calendar.google.com",
             :erik =>  "q30c6nh1r41acel29qmefstss8@group.calendar.google.com"}

def getTime(week, day, time)
    DateTime.parse("W#{week}-#{day} #{time.gsub(',',':')}+1").to_time
end

def getTimesArray(weekno, hours)
    hours.split(%r{\n}).map.with_index { |day, i|
        if !day.nil? && day != "LED" && !day.empty?
            times = day.split("-")
            [getTime(weekno, i+1, times[0]), getTime(weekno, i+1, times[1])]
        else
            nil
        end
    }
end

class Workday
    attr_accessor :from, :to, :name, :calendar
    
    def initialize(options = {})
        @from = options[:from]
        @to = options[:to]
        @name = options[:name]
        @calendar = $calendars[options[:name].downcase.to_sym] unless options[:name].nil?
    end
    
    def to_s
        "#{name}: #{from.strftime '%H:%M'} - #{to.strftime '%H:%M'}"
    end
end

class Daycare < Workday
    attr_accessor :leave, :pickup
    
    def initialize
        @name = "Agust"
        @calendar = $calendars[:agust]
    end

    def to_s
        "#{leave} lämnar, #{pickup} hämtar"
    end
end

def createEvent(workday)
    event = {
        'summary' => workday,
        'start' => { 'dateTime' => workday.from.to_datetime },
        'end' => { 'dateTime' => workday.to.to_datetime },
        }

    result = @client.execute(:api_method => @calendar.events.insert,
        :parameters => {'calendarId' => workday.calendar},
        :body => JSON.dump(event),
        :headers => {'Content-Type' => 'application/json'})    
end

def max(f1, f2, attr)
    a = f1.send attr
    b = f2.send attr
    a > b ? f1 : f2
end

getTimesArray(weekno, times).each_with_index do |day, i|
    erik = Workday.new(:name => "Erik",
        :from => getTime(weekno, i+1, "07:30"),
        :to => getTime(weekno, i+1, "16:00"))
    
    if !day.nil?
        anna = Workday.new :name => "Anna", :from => day[0], :to => day[1]

        if !((1..5) === anna.from.wday)
            createEvent(anna)
            break
        end

        agust = Daycare.new

        max = max(anna, erik, "from")
        agust.leave = max.name
        agust.from = max.from - 1800

        if anna.from.monday?
            agust.to = getTime(weekno, i+1, "14:00")

            if weekno.to_i.odd?
                agust.pickup = "Eva & Alf"
            else
                agust.pickup = "Karin & Anders"
            end
        else
            if anna.to > erik.to
                agust.pickup = erik.name
                erik.to = getTime(weekno, i+1, "15:00")
                agust.to = erik.to + 1800
            else
                agust.pickup = anna.name
                if anna.to > getTime(weekno, i+1, "13:30")
                    agust.to = anna.to + 1800
                else
                    agust.to = getTime(weekno, i+1, "14:00")
                end
            end
        end
    end

    createEvent(anna) unless anna.nil?
    createEvent(erik) unless erik.nil?
    createEvent(agust) unless agust.nil?
end
