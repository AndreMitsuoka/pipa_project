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
 
      puts "#{text[2]} #{text[3]}"
      total_cost = text[2]
      total_cost = total_cost.to_f
      
      puts "\ttext[1]: #{text[1]}\n"

      @check = user.dreams.where(:dream_name => text[1])  

      unless @check.count > 0

        if ((total_cost > 0.0) && (text[1] != nil))

          dream = user.dreams.create( 
                              :dream_name => text[1],
                              :cost => total_cost,
                              :value_per_week => 0.0,
                              :saved => 0.0,
                              :weekly_saved => 0.0,
                              :next_week => (Time.now)+604800,
                              :date => Time.now
          )

          sucess = dream
          puts "\n#{sucess}\n"

          if (!sucess.nil?)
            sms = "Sonho cadastrado! #{text[1]} que custa R$#{total_cost}"
            #sms2 = "Economizando R$#{save_per_week} em #{@time} semanas voce atingira sua meta."
            $GSM.send_sms!(user.phone_number,sms)
            #$GSM.send_sms!(user.phone_number,sms2)
            puts "#{sms}"
          else
            sms =  "Sonho nao cadastrado! Tente de novo."
            $GSM.send_sms!(user.phone_number,sms)
          end   
        else
          sms = "Formato errado da Mensagem!"
          puts "#{sms}"
          $GSM.send_sms!(user.phone_number,sms)
        end        
      else
        sms ="Sonho #{text[1]} ja esta cadastrado"
        puts "#{sms}"
        $GSM.send_sms!(user.phone_number,sms)  
      end


    when "consultar"  #retornar quando já foi atingido!
      dream = user.dreams.where(:dream_name => text[1]).first

      if ((dream.nil?) or (text[1].nil?))
        #if there is no param for dream search
        dream = user.dreams.all

        if dream.count > 0
          dream.each do |m|
            sms = "Sua meta e: #{m.dream_name} que custa R$#{m.cost}"
            puts "#{sms}\n"
            $GSM.send_sms!(user.phone_number,sms)
            sleep(2) #para não sobrecarregar esse modem
          end
        else
          sms = "Voce nao tem nenhum sonho cadastrado no momento"
          puts "#{sms}"    
          $GSM.send_sms!(user.phone_number,sms)
        end
      else
        percent = (100 * (dream.saved+dream.weekly_saved))/dream.cost
        sms = "Sua meta: #{dream.dream_name} que custa R$#{dream.cost}. Voce ja atingiu #{percent}% do seu sonho."
        $GSM.send_sms!(user.phone_number,sms)
        puts "#{sms}"
      end 
    when "economia"
      #604800 magic number! -> segundos em uma semana
      #interação economia dream_name economizado
      #no inicio do cadastro pedir economizar 
      dream = user.dreams.where(:dream_name => text[1]).first
      if ((dream.nil?) || (text[2].nil?))
        sms = "Sonho ou formato invalido, envie consultar para checar os sonhos cadastrados"
        $GSM.send_sms!(user.phone_number,sms)
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
          $GSM.send_sms!(user.phone_number,sms)

        else
          days = dreams_days(dream)
          #tempo em dias

          percent = 100*total/dream.cost #porcentagem do que falta
          total_days = (days *100)/percent #total de dias estimado
          #arredondar pro proximo int. ->se for quebrado

          if total_days.to_i == 0
            total_days = 1
          end # resolvendo problema do days = 0

          time_left = total_days.ceil.to_i - days.ceil.to_i # dias restantes
          sms = "Nesse Ritmo, faltam #{time_left} dias para atingir a meta. Voce ja atingiu #{percent.round(2)}% do seu sonho"
          $GSM.send_sms!(user.phone_number,sms)
        end
      end 
    when "comprar"  
    #sem retorno!
     #comprar interção composta "comprar produto valor [numero_de_ meses] "
     #cost = Sms.args_to_float(text)
     puts "hi comprar \n"
     value = text[2].to_f #the value
     dream = user.dreams
          puts "#{dream}"

     dream = dream.sort_by &:next_week
     #arrumar o sort |Definir o sort


     puts "#{dream}"


     parcelas = text[3] unless text[3].nil?  

     if (parcelas.to_i < 1 || parcelas.nil?)
        parcelas = 1
     end
     puts "parcelas #{parcelas}\n"

     if (dream.count >= 1)
        dream = dream.last
        puts "#{dream.dream_name}"
        if((dream.weekly_saved == 0) && (dream.saved == 0))
          sms = "Voce nunca cadastrou uma economia! Nesse ritmo voce nunca chegara la"      
          $GSM.send_sms!(user.phone_number,sms)
        else
          days = dreams_days(dream)   
          total = dream.weekly_saved + dream.saved
=begin
          percent = (100*total)/dream.cost #porcentagem do que falta
          total_days_before = (days *100)/percent #total de dias estimado

          if (total_days_before.ceil.to_i == 0)
            total_days_before = 1
          end # resolvendo problema do days = 0

          time_left_before = total_days.ceil.to_i - days.ceil.to_i # dias restantes antes da compra

          percent = (100*(total - (value*parcelas)))/dream.cost #porcentagem do que falta

          total_days_after = (days *100)/percent #total de dias estimado

          if total_days_after.ceil.to_i == 0
            total_days_after = 1
          end # resolvendo problema do days = 0

          time_left_after = total_days.ceil.to_i - days.ceil.to_i # dias restantes
=end 
          time = ((value/dream.weekly_saved)*7).ceil

          sms = "se voce comprar #{text[1]}, vai atrasar seu sonho em #{time} dias"
          $GSM.send_sms!(user.phone_number,sms)
        end     
     else
      sms = "Voce ainda nao tem sonhos cadastrados no sistema"
      $GSM.send_sms!(user.phone_number,sms)
     end

    
    
    when "conta" #LEMBRETE
      date = date_parse(text[2]) 
 
      puts "Data: #{date}"
      unless date.nil?
        bill = Bill.create( :name => text[1],
                            :date => date
          )
          user.bills << bill
          sucess = user.save
          sms = "Lembrete cadastrado com sucesso no dia #{date.to_s}!" 
          puts "#{sms}"   
          $GSM.send_sms!(user.phone_number,sms)
      else
        sms = "Data invalida!" 
        puts "#{sms}"   
        $GSM.send_sms!(user.phone_number,"Comando invalido")
      end

      ## ARRUMAR AQUI!
    when "agenda"
      #agenda nome dia
      date = Time.now
      date = date_parse(text[2])
      puts "#{date}\nmain\n" 
      unless (date.nil?)
        puts"unless\n"
        @check = user.agendas.where(:name => text[1])  #user.dream => dream 
        puts"#{@check.count}"

        unless(@check.count > 0)
          agenda = user.agendas.create( :name => text[1],
                                        :date => date
                                      )
            #user.agenda << agenda
            sucess = user.save

            puts "#{sucess}"

            sms = "Agenda cadastrada com sucesso no dia #{date.to_s}!" 
            puts "#{sms}"   
            $GSM.send_sms!(user.phone_number,sms)
        else
            sms = "Voce ja tem um lembrete com esse nome: #{text[1]}!" 
            puts "#{sms}"   
            $GSM.send_sms!(user.phone_number,sms)
        end
      else 
        sms = "Data invalida!" 
        puts "#{sms}"   
        $GSM.send_sms!(user.phone_number,sms)
      end
    else #default of switch
      sms = "Comando invalido no pipa!" 
      puts "#{sms}"   
      $GSM.send_sms!(user.phone_number,sms)
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
      return date
    rescue ArgumentError
      puts "Data invalida!"
      return nil
    end #begin 
  end 

  def self.dreams_days(dream)
    days = (Time.now - dream.date)/86400 #tempo em dias
    if days.to_i == 0
        days = 1
    end # resolvendo problema do days = 0
    days
  end

  def self.dreams_weeks(dream)
    weeks = (Time.now - dream.date)/604800 #tempo em semanas
    if weeks.to_i == 0
      weeks = 1
    end # resolvendo problema do days = 0
    weeks.ceil.to_i
  end

end
