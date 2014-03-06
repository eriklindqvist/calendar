#encoding: utf-8

curweek = 11

times = "10:00 – 17:00; 08:00 – 12:30; 09:15 – 18:15; 08:00 – 19:15; 10:00 – 15:00
08:00 – 17:00; 08:15 – 15:30; ; 12:00 – 19:15; 09:00 – 17:00
09:00 – 15:00; ; 08:00 – 14:00; 10:00 – 18:15; 11:00 – 19:15
"

weeks = times.gsub('–','').split(%r{\n}).map{|week| week.split(';')}.collect {|week| week.collect{|day| day.strip.split }}

weeks.each do |week|    
    i = 0
    week.each do |day|
        i += 1
        puts "day: #{i}, from: #{day[0]}, to: #{day[1]}"
    end
    curweek += 1
end