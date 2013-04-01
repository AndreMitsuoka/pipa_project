
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
                              :cost => cost
        )
        user.dreams << dream
        sucess = user.save

        if sucess
          puts "Sonho cadastrado!"
          #$GSM.send_sms!(user.phone_number,sms)
        else
          puts "Sonho não cadastrado!"
          #$GSM.send_sms!(user.phone_number,sms)
        end   
      else
        puts "Custo zuado ou sem custo "
        #$GSM.send_sms!(user.phone_number,sms)

      end 

    when "consultar"  

      dream = user.dreams.where(:dream_name => text[1]).first

      if (dream.nil?)
        puts "NAO ACHO!\n"
        #$GSM.send_sms!(user.phone_number,"Nao encontramos sua busca")
      else
        sms = "Sua meta e: #{dream.dream_name} que custa R$#{dream.cost}"
        #$GSM.send_sms!(user.phone_number,sms)
        puts "ACHOU! Sua meta e: #{dream.dream_name} que custa R$#{dream.cost}"
      end

    when "comprar"  
	cost = Sms.args_to_float(text)
	time = cost/(user.incoming - user.outgoing)

	sms = "Gastar #{cost} poderia atrasar sua meta em #{time} semanas/meses."
        $GSM.send_sms!(user.phone_number,sms)
  
    else  
      $GSM.send_sms!(user.phone_number,"Comando invalido")
    end
  end

public

  def self.argsToFloat(text)
    puts("func\n")
    if text[3] != nil
        cost_float = text[2]+"."+text[3] #getting toguether real value with cents value
      else
        cost_float = text[2]
      end
      cost = cost_float.to_f
  end 


end
