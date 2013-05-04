class Sms

  def self.msg_interpretation(msg,user)
    
    #make the text an array of each word or element
    text = msg.text.downcase
    puts "#{text}"
    text = text.removeaccents
    text = text.scan(/[\w']+[\d]*[.|,]*/)

    puts "Hello: #{text}"


    #The first word in the sms defines which action to take
    case text[0]

    when "cadastrar" 
      #later check if the dream already exists
      puts "hey ho ho #{text[2]} #{text[3]}"
      total_cost = text[2]
      total_cost = total_cost.to_f
      #save_per_week = text[3]
      # => save_per_week = save_per_week.to_f

      puts "\ttext[1]: #{text[1]}\n"

      @check = Dream.where(:dream_name => text[1]) 

      puts "#{@check.count}"

      unless @check.count > 0

        if ((total_cost >= 0) && (save_per_week >= 0))
          
          dream = Dream.create( :dream_name => text[1],
                              :cost => total_cost,
                              :value_per_week => 0.0,
                              :saved => 0.0,
                              :weekly_saved => 0.0,
                              :next_week => (Time.now)+604800,
                              :date => Time.now
          )
          user.dreams << dream
          sucess = user.save
          puts "#{sucess}\n"

          if (sucess == true)
              #@time = (total_cost/save_per_week)

              #if (@time.to_f > @time.to_i) 
               # @time = @time+1
               # @time = @time.to_i
              #end

            sms = "Sonho cadastrado! #{text[1]} que custa R$#{total_cost}"
            #sms2 = "Economizando R$#{save_per_week} em #{@time} semanas voce atingira sua meta."
            #$GSM.send_sms!(user.phone_number,sms)
            #$GSM.send_sms!(user.phone_number,sms2)
            puts "#{sms}\n#{sms2}"
          else
            sms =  "Sonho nao cadastrado! Tente de novo."
            #$GSM.send_sms!(user.phone_number,sms)
          end   
        else
          sms = "Formato errado da Mensagem!"
          puts "#{sms}"
          #$GSM.send_sms!(user.phone_number,sms)
        end        
      else
        sms ="Sonho #{text[1]} ja esta cadastrado"
        puts "#{sms}"
        #$GSM.send_sms!(user.phone_number,sms)  
      end


    when "consultar"  
      dream = user.dreams.where(:dream_name => text[1]).first

      if ((dream.nil?) or (text[1].nil?))
        #if there is no param for dream search
        dream = user.dreams.all

        if dream.count > 0
          dream.each do |m|
            sms = "Sua meta e: #{m.dream_name} que custa R$#{m.cost}"
            puts "#{sms}\n"
            $GSM.send_sms!(user.phone_number,sms)
          end
        else
          sms = "Voce nao tem nenhum sonho cadastrado no momento"
          puts "#{sms}"    
          $GSM.send_sms!(user.phone_number,sms)
        end
      else
        percent = (100 * dream.saved)/dream.cost
        sms = "Sua meta: #{dream.dream_name} que custa R$#{dream.cost}. Voce ja atingiu #{percent}% do seu sonho."
        $GSM.send_sms!(user.phone_number,sms)
        puts "#{sms}"
      end 
    when "economia"
      #604800 magic number! -> segundos em uma semana
      #interação economia dream_name economizado
      dream = user.dreams.where(:dream_name => text[1]).first
      if ((dream.nil?) || (text[2].nil?))
        sms = "Sonho ou formato invalido, envie consultar para checar os sonhos cadastrados"
        #$GSM.send_sms!(user.phone_number,sms)
        puts "#{sms}"
      else
        user_save = text[2].to_f
        time = Time.now
        if (time > dream.next_week)

          dream.saved += dream.weekly_saved
          while time > dream.next_week
              dream.next_week = dream.next_week+604800
          end 
          dream.save
          dream.weekly_saved = user_save
        else
          dream.weekly_saved = dream.weekly_saved + user_save
          dream.save
        end
        total = dream.weekly_saved + dream.saved
        if(dream.cost <= total)
          sms = "Parabens Voce atingiu seu sonho"
          #$GSM.send_sms!(user.phone_number,sms)

        else
          # 86400 -> segundos em um dia
          days = (Time.now - dream.date)/86400 #tempo em dias
          if days.to_i == 0
            days = 1
          end # resolvendo problema do days = 0

          percent = 100*total/dream.cost #porcentagem do que falta
          total_days = (days *100)/percent #total de dias estimado

          if total_days.to_i == 0
            total_days = 1
          end # resolvendo problema do days = 0

          time_left = total_days.to_i - days.to_i # dias restantes
          sms = "Nesse Ritmo, faltam #{time_left} dias para atingir a meta, isso e #{percent.round(2)}% do seu sonho"

          #$GSM.send_sms!(user.phone_number,sms)
        end
      end 
    when "comprar"  
     #comprar interção composta "comprar produto valor numero_de_ meses "
     #cost = Sms.args_to_float(text)

     dream = user.dreams
     dream = dream.sort_by &:next_week

     if dream.count >= 1
       dream = dream.first
        if(dream.weekly_saved == 0 && dream.saved == 0)
          sms = "Voce nunca cadastrou uma economia! Nesse ritmo voce nunca chegara la"      
        else

        end  
        
     else
      sms = "Voce ainda nao tem sonhos cadastrados no sistema"
     end

     
      #sms = "Gastar #{cost} poderia atrasar sua meta em #{time} semanas/meses."
      #$GSM.send_sms!(user.phone_number,sms)
    
    when "conta" #LEMBRETE
      date = date_parse(text[2]) 
 
      puts "Data: #{date}"
      unless date.nil?
        bill = Bill.create( :name => text[1],
                            :date => date
          )
          user.bills << bill
          sucess = user.save
      else
        sms = "Data invalida!" 
        puts "#{sms}"   
        #$GSM.send_sms!(user.phone_number,"Comando invalido")
      end
    end
  end

private

  def self.date_parse(set_date)
    begin
      date = ""
      today_info = Time.now
      date << today_info.year.to_s
     date << today_info.month.to_s

      if (!date[5]) #add 0 in front of a number with one digit ex: 4/4/2013 => 04/04
       date[5] = date[4]
       date[4] = "0"
     end

     date << set_date

      if (!date[7])
        date[7] = date[6]
       date[6] = "0"
      end
      rescue
        puts "Argumento invalido"
        return nil
      end #begins
    puts"Date : #{date}"
    begin
      date = Date.strptime(date,"%Y%m%d")


      date = date.yesterday
      puts "#{date}"

      if (date.past?)
        date = date.next_month
        puts "#{date}"
        date
      end
      date
    rescue ArgumentError
      puts "Data invalida!"
      return nil
    end #begin 
  end 

  def self.dreams_days(dream)
    days = (Time.now - dream.date)/86400 #tempo em dias
    days.to_i
  end

  def self.dreams_weeks(dream)
    weeks = (Time.now - dream.date)/604800 #tempo em dias
    weeks.round(1).to_i
  end


end
