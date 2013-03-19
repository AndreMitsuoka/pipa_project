
class ReverseApp
    def initialize(gsm)
        gsm.receive(method(:incoming))
        @gsm = gsm
    end

    def incoming(from, datetime, message)
        puts("incoming \n #{message}")
        #@gsm.send(from, message.reverse)
    end
end

#gsm = Gsm::Modem.new
#ReverseApp.new(gsm)