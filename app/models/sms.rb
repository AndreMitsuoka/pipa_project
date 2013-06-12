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
      total_cost = text[2].to_f
      name = text[1]

      puts "\tname: #{name}\n"

      var = cadastro(user,total_cost,name)

    when "consultar"  #retornar quando já foi atingido!
      dream_name = text[1]
      var = consulta(user,dream_name)

    when "economia"
      #604800 magic number! -> seconds in a week
      #interação economia dream_name economizado
      dream_name = text[1]
      value = text[2].to_f
      

      puts "#{dream_name}, #{value}\n"
      var = economiza(user,dream_name,value) 

    when "comprar"  
     #comprar interção composta "comprar produto valor [numero_de_ meses] "
     desire = text[1]
     value = text[2].to_f #the value
     dream = user.dreams
     puts "#{dream}"

     dream = dream.sort_by &:updated_at
     #arrumar o sort |Definir o sort
     puts "#{dream}"

     parcelas = text[3] unless text[3].nil?  

     if (parcelas.to_i < 1 || parcelas.nil?)
        parcelas = 1
     end
     puts "parcelas #{parcelas}\n"

     if(value <= 0.0 || dream == "" || desire == "")
        sms = "Formato da mensagem invalido!" 
        enviar_e_print(user,sms)

     else   
      var = compra(user,dream,value,parcelas,desire)
     end

      
    when "conta" #LEMBRETE
      #conta nome dia
      #verificar como ele retorna o dia
      date = date_parse(text[2]) 
 
      puts "Data: #{date}"
      unless date.nil?
        bill = Bill.create( :name => text[1],
                            :date => date
          )
          user.bills << bill
          sms = "Lembrete cadastrado com sucesso no dia #{date.tomorrow.to_s}!" 
          enviar_e_print(user,sms)

      else
        sms = "Data invalida!" 
        enviar_e_print(user,sms)

      end

    when "agenda"
      #agenda nome dia
      #mandar msg pra amanhã
      
      date = Time.now
      date = date_parse(text[2])
      puts "#{date}\nmain\n" 
      unless (date.nil?)
        puts"unless\n"
        @check = user.agendas.where(:name => text[1])  #user.dream => dream 
        puts"#{@check.count}"
        unless(@check.count > 0)
          begin
          agenda = Agenda.new( :name => text[1],
                                        :date => date
                                      )
            user.agendas << agenda

            sms = "Agenda cadastrada com sucesso no dia #{date.tomorrow.to_s}!" 
            enviar_e_print(user,sms)
          rescue
            sms = "Voce ja tem um lembrete com esse nome: #{text[1]}!" 
            enviar_e_print(user,sms)
          end
      else 
        sms = "Data invalida!" 
        enviar_e_print(user,sms)

      end
    else #default of switch
      sms = "Comando invalido no pipa!" 
      enviar_e_print(user,sms)
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
      unless (@check.count > 0)

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

            #user.dreams << dream
            puts "#{user.phone_number} #{dream}\n"
            sms = "Sonho cadastrado! #{name} que custa R$#{total_cost}"
            enviar_e_print(user,sms)
            
          rescue Exception => e  
             puts e.message  
              puts e.backtrace.inspect  
              sms =  "Sonho nao cadastrado! Tente de novo."
              enviar_e_print(user,sms)
          end
        else
          sms = "Formato errado da Mensagem!"
          enviar_e_print(user,sms)
        end        
      else
        sms ="Sonho #{name} ja esta cadastrado"
        enviar_e_print(user,sms)
      end  
 end

  def self.consulta(user,dream_name)
    dream = user.dreams.where(:dream_name => dream_name).first

      if ((dream.nil?) or (dream_name.nil?))
        #if there is no param for dream search
        dream = user.dreams.all

        if (dream.count > 0)
          dream.each do |m|
            sms = "Sua meta e: #{m.dream_name} que custa R$#{m.cost}"
            enviar_e_print(user,sms)
            sleep(2) #give a break to the modem :)
          end
        else
          sms = "Voce nao tem nenhum sonho cadastrado no momento"
          enviar_e_print(user,sms)

        end
      else
        percent = (100 * (dream.saved+dream.weekly_saved))/dream.cost
        sms = "Sua meta: #{dream.dream_name} que custa R$#{dream.cost}. Voce ja atingiu #{percent}% do seu sonho."
        enviar_e_print(user,sms)

      end 
  end

  def self.economiza(user,dream_name,value)

    puts "#{dream_name}, #{value}\n"
    dream = user.dreams.where(:dream_name => dream_name).first

      if ((dream.nil?) || (value.nil?))
        sms = "Sonho ou formato invalido, envie consultar para checar os sonhos cadastrados"
        enviar_e_print(user,sms)
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
          enviar_e_print(user,sms)
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
          enviar_e_print(user,sms)
          dream.update_attribute(:updated_at,Time.now)
        end
      end 
  end

  def self.compra(user,dream,value,parcelas,desire)

    if (dream.count >= 1)
        dream = dream.last
        puts "#{dream.dream_name}"

        if((dream.weekly_saved == 0) && (dream.saved == 0))
          sms = "Voce nunca cadastrou uma economia para #{dream.dream_name}!Caso compre #{desire} ira demorar ainda mais..."      
          enviar_e_print(user,sms)
        else
          days = dreams_days(dream)   
          total = dream.weekly_saved + dream.saved

          time = ((value/dream.weekly_saved)).ceil

          enviar_e_print(user,sms)
        end     
    else
      sms = "Voce ainda nao tem sonhos cadastrados no sistema" 
      enviar_e_print(user,sms)
     end
  end

  def self.enviar_e_print(user,sms)
    $GSM.send_sms!(user.phone_number,sms)
    puts "#{sms}\n"
  end

end

