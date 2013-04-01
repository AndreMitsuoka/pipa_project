#encoding: utf-8
class Modem < ActiveRecord::Base
  
    def initialize(gsm)
    	  gsm.receive() #Chamo o método de Users na própria GEM  
        @gsm = gsm
    end
    
end