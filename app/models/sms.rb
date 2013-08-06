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
 
      total_cost = text[2].to_f
      name = text[1]

      var = cadastro(user,total_cost,name)

    when "consultar"  #retornar quando já foi atingido!
      dream_name = text[1]
      var = consulta(user,dream_name)

    when "economia"
      #604800 magic number! -> seconds in a week
      #interação economia dream_name economizado
      dream_name = text[1]
      value = text[2].to_f
      
      var = economiza(user,dream_name,value) 

    when "comprar"  
     #comprar interção composta "comprar produto valor [numero_de_ meses] "
     desire = text[1]
     value = text[2].to_f #the value
     dream = user.dreams
     puts "#{dream}"

     dream = dream.sort_by &:updated_at
     #arrumar o sort |Definir o sort

     parcelas = text[3] || 1 

     puts "parcelas #{parcelas}\n"

     if(value <= 0.0 || dream == "" || desire == "")
        sms = "Formato da mensagem invalido!" 
        send_and_print(user,sms)
     else   
      
      var = compra(user,dream,value,parcelas,desire)
     end
      
    when "conta" #LEMBRETE
      #conta nome dia
      sms = ""
      date = date_parse(text[2]) 
 
      puts "Data: #{date}"

      @check = user.bills.where(:name => text[1])  


      if  ( !(date.nil?) && ( @check.count == 0 ) )
          begin 
            bill = Bill.create( :name => text[1],
                                :date => date
                            )
            user.bills << bill
            sms = "Lembrete cadastrado com sucesso no dia #{date.tomorrow.to_s}!" 
          rescue
            sms = "Houve uma falha, cadatre novamente a conta!"
          end
      else
        sms = "Data invalida ou lembrete ja cadastrado com esse nome!" 
      end
      send_and_print(user,sms)


    when "agenda"
      #agenda nome dia
      sms=""
      
      date = Time.now
      date = date_parse(text[2])

     @check = user.agendas.where(:name => text[1])  

      
      if ( !(date.nil?) && ( @check.count == 0 ) )

          begin
            agenda = Agenda.new( :name => text[1],
                                 :date => date
                               )
            user.agendas << agenda
            sms = "Agenda cadastrada com sucesso no dia #{date.tomorrow.to_s}!" 
          rescue
            sms = "Houve uma falha, cadatre novamente a conta!"
          end
      else 
        sms = "Data invalida ou lembrete ja cadastrado com esse nome!" 
      end
      send_and_print(user,sms)

  when "excluir"    
     dream =  text[1]
     exclui(user, dream)
    else #default of switch
      sms = "Comando invalido no pipa!" 
      send_and_print(user,sms)
    end
  end


private

  def self.exclui(user,dream_name)
 
      dream = user.dreams.where(:dream_name => dream_name).first

      if ((dream.nil?) ||(dream_name.nil?) )
        sms = "Voce nao tem nenhum sonho cadastrado com esse nome no momento"
      else
        dream.destroy
        user.update_attribute(:number_dreams,user.number_dreams - 1 )

        sms = "Sonho excluido com sucesso!"
      end
      send_and_print(user,sms)
    

  end

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



  def self.cadastro(user,total_cost,name)
      @check = user.dreams.where(:dream_name => name)  
      puts "#@check: #{@check.count}\n"
      unless (@check.count > 0 || (user.number_dreams == 5))

        if ((total_cost > 0.0) && (name != nil))
          
          begin 
            puts "#{total_cost} #{name} #{user.phone_number}"

            dream = user.dreams.create( 
                  :dream_name => name,
                  :cost => total_cost,
                  :value_per_week => 0.0,
                  :saved => 0.0,
                  :weekly_saved => 0.0,
                  :next_week => (Time.now)+604800,
                  :date => Time.now,
                  :updated_at => ""
            )

            user.update_attribute(:number_dreams,user.number_dreams + 1 )
            user.save

            #user.dreams << dream
            puts "#{user.phone_number} #{dream}\n"
            sms = "Sonho cadastrado! #{name} que custa R$ #{total_cost}"
            send_and_print(user,sms)
            
          rescue Exception => e  
              puts e.message  
              puts e.backtrace.inspect  
              log.debug user.errors.full_messages
              puts "#{@user.errors.full_messages}"

              sms =  "Sonho nao cadastrado! Tente de novo."
              send_and_print(user,sms)
          end
        else
          sms = "Formato errado da Mensagem!"
          send_and_print(user,sms)
        end        
      else
        sms ="Sonho #{name} ja esta cadastrado ou voce ja atingiu o numero maximo de sonhos simultaneos"
        send_and_print(user,sms)
      end  
 end

  def self.consulta(user,dream_name)
    if (dream_name.nil?)
      dream = user.dreams.all

      if (dream.count == 0)
              sms = "Voce nao tem nenhum sonho cadastrado!"
        send_and_print(user,sms)
      end
        dream.each do |m|    
          sms = "Sua meta e: #{m.dream_name} que custa R$ #{m.cost}"
          send_and_print(user,sms)
          sleep(1) #give a break to the modem :)
        end

    else
      dream = user.dreams.where(:dream_name => dream_name).first
      if (dream.nil?)
        sms = "Voce nao tem nenhum sonho cadastrado com esse nome no momento"
      else
        percent = (100 * (dream.saved+dream.weekly_saved))/dream.cost
        sms = "Sua meta: #{dream.dream_name} que custa R$ #{dream.cost}. Voce ja atingiu #{percent}% do seu sonho."
      end
      send_and_print(user,sms)
    end
  end

  def self.economiza(user,dream_name,value)

    dream = user.dreams.where(:dream_name => dream_name).first

      if ((dream.nil?) || (value.nil?))
        sms = "Sonho ou formato invalido, envie consultar para checar os sonhos cadastrados"
        send_and_print(user,sms)
      else
        user_save = value.to_f
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
          sms3 = "Parabens, voce atingiu seu sonho \"#{dream.dream_name}\"!!!"
          send_and_print(user,sms3)

          user.update_attribute(:number_dreams,user.number_dreams - 1 )
          user.save
          dream.destroy
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
          send_and_print(user,sms)
          dream.update_attribute(:updated_at,Time.now)
        end
      end 
  end

  def self.compra(user,dream,value,parcelas,desire)
    #compra verficar o que manda 
    sms="" 
    days = 0
    total =0.0
    saved_during_week = 0.0
    if (dream.count >= 1)

        dream.each do |m|
          total = (m.weekly_saved||=0.0 ) + (m.saved ||=0.0) + (total ||=0.0)
          saved_during_week = (saved_during_week ||= 0.0) +(m.weekly_saved||=0.0 ) 
        end

        if(total == 0.0 )
          sms = "Voce nunca cadastrou uma economia para os seus sonhos!Caso compre #{desire} ira demorar ainda mais..."      
        else

          dream.each do |m|
            days = dreams_days(m)+(days||=0)     
          end

          time = (value/(saved_during_week||=1)).ceil
          sms = "Se comprar #{desire} vai atrasar os seus sonhos em #{time} dia(s)."
        end     
    else
      sms = "Voce ainda nao tem sonhos cadastrados no sistema" 
     end
     send_and_print(user,sms)

  end

  def self.send_and_print(user,sms)
    $GSM.send_sms!(user.phone_number,sms)
    puts "#{sms}\n"
  end

end

