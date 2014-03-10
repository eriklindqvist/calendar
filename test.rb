#encoding: utf-8
require 'date'

def getTime(week, day, time)
    DateTime.parse("W#{week}-#{day} #{time}+1").to_time
end

def t(t)
    t.strftime '%H:%M' unless t.nil?
end

times = "Vecka; Måndag; Tisdag; Onsdag; Torsdag; Fredag
11; 10:00 – 17:00; 08:00 – 12:30; 09:15 – 18:15; 08:00 – 19:15; 10:00 – 15:00
12; 08:00 – 17:00; 08:15 – 15:30; ; 12:00 – 19:15; 09:00 – 17:00
13; 09:00 – 15:00; ; 08:00 – 14:00; 10:00 – 18:15; 11:00 – 19:15"

values = times.gsub('–','').split(%r{\n}).map{|week| week.split(';')}.collect {|week| week.collect{|day| day.strip.split }}
titles = values[0][1..-1].flatten
weeks = values[1..-1]

erikstart = "07:30"
erikend = "16:00"

weeks.each do |week|
    week[1..-1].each_with_index do |day, j|
        if day[0]
            weeknum = week[0][0]
            
            annafrom = getTime(weeknum, j+1, day[0])
            erikfrom = getTime(weeknum, j+1, erikstart)
            
            annato = getTime(weeknum, j+1, day[1])
            erikto = getTime(weeknum, j+1, erikend)
            
            if annafrom > erikfrom
                leave = "Anna"
                agustfrom = annafrom - 1800 # 30 min tidigare
            else
                leave = "Erik"
                agustfrom = erikfrom - 1800 # 30 min tidigare
            end
            
            if j==0
                agustto = getTime(weeknum, j+1, "14:00")
                
                if week[0][0].to_i.odd?
                    pickup = "Eva & Alf"
                else
                    pickup = "Karin & Anders"
                end
            else
                if annato > erikto
                    pickup = "Erik"
                    erikto = getTime(weeknum, j+1, "15:00")
                    agustto = erikto + 1800
                else
                    pickup = "Anna"
                    if annato > "13:30"
                        agustto = annato + 1800
                    else
                        agustto = "14:00"
                    end
                end
            end
            
            puts "#{annafrom.to_date}"
            puts "Agust: #{leave} #{t(agustfrom)} - #{t(agustto)} #{pickup}"
            puts "Anna: #{t(annafrom)} - #{t(annato)}"
            puts "Erik: #{t(erikfrom)} - #{t(erikto)}"
            puts ""
        end
    end    
end