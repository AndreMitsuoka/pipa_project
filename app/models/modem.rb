#encoding: utf-8
require 'net/http'

class Modem 

    def initialize(gsm)

    	  Modem.listening_day()
          Thread.current[:name] = "Initialize"
    	  Thread.list.each {|a| puts " 1 -#{a.inspect}: #{a[:name]}"}
          begin 
    	   gsm.receive() 
        
           @gsm = gsm

         rescue Exception => e  
              puts e.message  
              puts e.backtrace.inspect  
              log.debug @gsm.errors.full_messages
            puts "#{@gsm.errors.full_messages}"
            puts "Error in Modem Constructor"
            @gsm.reset!
          end

    end

    def self.listening_day()

    	Thread.new{
            Thread.current[:name] = "Listening_day"

    		Thread.list.each {|a| puts " 1 -#{a.inspect}: #{a[:name]}"}
            count = 7

            while(1)
        		while (Time.now.hour != 18 )
        			sleep(3600) #magic day number
        			puts"hey"
        		end

        		Bill.all.each  do |a| 
                    puts "#{a.date.day}"
        			if (Time.now.day == a.date.day)
        				user = User.where(:id => a.user_id).first 
        				name_bill = a.name
                        sms = "Amanha pagar sua conta de #{name_bill}."
                        puts "#{sms}"
        				#$GSM.send_sms!(user.phone_number,sms)
        				a.date = a.date.next_month #verificar se está salvando no próximo mês
        			    puts "#{a.date}"
                    end
        		end
                Agenda.all.each  do |a| 
                    puts "#{a.date.day}"
                    if (Time.now.day == a.date.day)
                        user = User.where(:id => a.user_id).first 
                        name_agenda = a.name
                        sms = "Lembrete de #{name_agenda} amanha."
                        puts "#{sms}"
                        #$GSM.send_sms!(user.phone_number,sms)
                        a.destroy
    
                    end
                end

                if((count%7) == 0 ) #just do  once a week
                    Dream.all.each do |d|
                        days = Time.now - d.next_week
                        if(days >= 604800)
                            user = User.where(:id => d.user_id).first 
                            sms = "Vamos la, faz tempo que nao economiza nada!"
                            #$GSM.send_sms!(user.phone_number,sms)
                        end
                    end
                end
                sleep(3600*20) #wait 20h to listening again
                count +=1
            end
    	}
    end

  
    
end