
class GSMApp
    def initialize(gsm)
    	  gsm.receive() #Chamo o método de Users na própria GEM  
        @gsm = gsm
    end

    def incoming(from, datetime, message)
        puts("incoming \n #{message}")
        #@gsm.send(from, message.reverse)
    end
end

gsm = Gsm::Modem.new  #cria o Modem, mas deixa a sessão inativa
GSMApp.new(gsm)