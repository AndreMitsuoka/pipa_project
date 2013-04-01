
class Sms #< ActiveRecord::Base



  def self.msg_interpretation(msg,user)
    
    #make the text an array of each word or element
    text = msg.text.downcase.scan(/[\w']+/)
    
    #The first word in the sms defines which action to take
    case text[0]

    when "cadastrar" 
      #checar se o sonho já existe

      cost = argsToFloat(text)

      puts "\n#{cost}\t#{text[1]}\n"

      if cost >= 0 
        dream = Dream.create( :dream_name => text[1],
                              :cost => cost,
                              :saved => 0.0
        )
        user.dreams << dream
        sucess = user.save

        if sucess
          puts "Sonho cadastrado!"
          #$GSM.send_sms!(user.phone_number,sms)
        else
          puts "Sonho nao cadastrado!"
          #$GSM.send_sms!(user.phone_number,sms)
        end   
      else
        puts "Custo zuado ou sem custo "
        #$GSM.send_sms!(user.phone_number,sms)
      end 

    when "consultar"  
      dream = user.dreams.where(:dream_name => text[1]).first

      if ((dream.nil?) or (text[1].nil?))
        dream = user.dreams.all

        if dream.count > 0
          dream.each do |m|
            sms = "Sua meta e: #{m.dream_name} que custa R$#{m.cost}"
            puts "#{sms}\n"
            #$GSM.send_sms!(user.phone_number,sms)
          end
        else
          puts "Voce nao tem nenhum sonho cadastrado no momento"   
          #$GSM.send_sms!(user.phone_number,"Nao encontramos seu sonho")
        end
      else
        sms = "Sua meta e: #{dream.dream_name} que custa R$#{dream.cost}"
        #$GSM.send_sms!(user.phone_number,sms)
        puts "ACHOU! Sua meta e: #{dream.dream_name} que custa R$#{dream.cost}"
      end 
    when "economia"
      dream = user.dreams.where(:dream_name => text[1]).first
      if (dream.nil?)
        puts "NAO ACHO!\n"
        #$GSM.send_sms!(user.phone_number,"Nao encontramos seu sonho")
      else
        value_per_week= argsToFloat(text)
        weeks = dream.cost/(value_per_week)
        if weeks > 4
          months = weeks/4
          weeks = weeks%4
        else
          months = 0
        end

        dream.saved = dream.saved + value_per_week
        dream.weeks = weeks

        if dream.save >= dream.cost
          puts "Parabens voce atingiu seu sonho!"
          #DESTRUIR O SONHO DEPOIS 
        else
          percent = (value_per_week * 100)/dream.cost

          sms = "Sua meta e: #{dream.dream_name} que custa R$#{dream.cost},
           nesse ritmo em #{months} meses e #{weeks} semanas voce atingira seu sonho."
          puts "#{sms}"        
          sms = "Voce ja atingiu #{percent}% do seu sonho!"
          puts "#{sms}"        
          #$GSM.send_sms!(user.phone_number,sms)
        end
      end 
    when "comprar"  
     # cost = Sms.args_to_float(text)
     # time = cost/(user.incoming - user.outgoing)

      #sms = "Gastar #{cost} poderia atrasar sua meta em #{time} semanas/meses."
      #$GSM.send_sms!(user.phone_number,sms)
    else  
      $GSM.send_sms!(user.phone_number,"Comando invalido")
    end
  end

public

  def self.argsToFloat(text)
    if text[3] != nil
        cost_float = text[2]+"."+text[3] #getting toguether real value with cents value
      else
        cost_float = text[2]
      end
      cost = cost_float.to_f
  end 


end
