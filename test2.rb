#encoding: utf-8
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

def getTime(week, day, time)
    DateTime.parse("W#{week}-#{day} #{time.gsub(',',':')}+1").to_time
end

def t(t)
    t.strftime '%H:%M' unless t.nil?
end

def getTimesArray(weekno, hours)
    days = hours.split(%r{\n})
    d = days.map.with_index do |day, i|
        if !day.nil? && day != "LED" && !day.empty?
            times = day.split("-")
            [getTime(weekno, i+1, times[0]), getTime(weekno, i+1, times[1])]
        end
    end
    d.compact
end

getTimesArray(weekno, times).each do |day|
    puts "from: #{t(day[0])}"
    puts "to: #{t(day[1])}"
end
