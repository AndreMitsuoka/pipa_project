#encoding: utf-8
class Modem 

    def initialize(gsm)

    	  Modem.listening_day()

    	  Thread.list.each {|a| puts " 1 -#{a.inspect}: #{a[:name]}"}
          begin 
    	   gsm.receive() 
        
           @gsm = gsm
          rescue
            puts "Error in Modem Constructor"
          end

    end

    def self.listening_day()

    	Thread.new{
    		Thread.list.each {|a| puts " 1 -#{a.inspect}: #{a[:name]}"}

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
    				a.date = a.date.next_month
    			    puts "#{a.date}"
                end
    		end
    	}
    end

  
    
end