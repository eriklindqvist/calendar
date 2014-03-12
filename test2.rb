#encoding: utf-8
require 'date'

times = "10,00-18,30
10,00-17,00
8,30-19,15
LED
11,00-19,15
LED
11,00-14,00
"

if ARGV.length == 0
    puts "Usage: blablabal"
    exit 1
end

weekno = ARGV[0]

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

weekdays = ["Söndag","Måndag","Tisdag","Onsdag","Torsdag","Fredag","Lördag"]

getTimesArray(weekno, times).each do |day|
    anna = Workday.new day[0], day[1]    
    weekday = weekdays[anna.from.wday]
    
    if !((1..5) === anna.from.wday)
        puts "#{weekday} - Anna: #{anna}"
        break
    end
    
    erik = Workday.new(
        Time.new(anna.from.year, anna.from.month, anna.from.day, 7, 30),
        Time.new(anna.from.year, anna.from.month, anna.from.day, 16, 0))
    
    agust = Workday.new
    
    if anna.from > erik.from
        leave = "Anna"
        agust.from = anna.from - 1800 # 30 min tidigare
    else
        leave = "Erik"
        agust.from = erik.from - 1800 # 30 min tidigare
    end
    
    if anna.from.monday?
        agust.to = Time.new(anna.from.year, anna.from.month, anna.from.day, 14, 0)

        if weekno.to_i.odd?
            pickup = "Eva & Alf"
        else
            pickup = "Karin & Anders"
        end
    else
        if anna.to > erik.to
            pickup = "Erik"
            erik.to = Time.new(anna.from.year, anna.from.month, anna.from.day, 15, 0)
            agust.to = erik.to + 1800
        else
            pickup = "Anna"
            if anna.to > Time.new(anna.from.year, anna.from.month, anna.from.day, 13, 30)
                agust.to = anna.to + 1800
            else
                agustto = Time.new(anna.from.year, anna.from.month, anna.from.day, 14, 0)
            end
        end
    end

    puts "#{weekday} - Anna: #{anna}, Erik: #{erik}, Agust #{agust}, #{leave} lämnar, #{pickup} hämtar"
end
