#encoding: utf-8
require 'date'

times = "Vecka; Måndag; Tisdag; Onsdag; Torsdag; Fredag
11; 10:00 – 17:00; 08:00 – 12:30; 09:15 – 18:15; 08:00 – 19:15; 10:00 – 15:00
12; 08:00 – 17:00; 08:15 – 15:30; ; 12:00 – 19:15; 09:00 – 17:00
13; 09:00 – 15:00; ; 08:00 – 14:00; 10:00 – 18:15; 11:00 – 19:15"

values = times.gsub('–','').split(%r{\n}).map{|week| week.split(';')}.collect {|week| week.collect{|day| day.strip.split }}
titles = values[0][1..-1].flatten
weeks = values[1..-1]

weeks.each do |week|
    week[1..-1].each_with_index do |day, j|
        date = Date.parse("W#{week[0][0]}-#{j+1}")
        puts "#{date} #{day[0]} - #{day[1]}" unless !day[0]
    end    
end