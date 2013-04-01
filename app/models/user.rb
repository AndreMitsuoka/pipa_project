#encoding: utf-8
class User < ActiveRecord::Base
  attr_accessible :phone_number,:name,:number_dreams,:incoming , :outgoing

  has_many :dreams
    #$GSM.send_sms!('+551581144047','I am working dude!')


  def self.find_for_user(msg)

    #find for phone_number
    user = User.where(:phone_number => msg.sender).first  

    unless user
      user = User.create(  :phone_number => msg.sender)
    end
    Sms.msg_interpretation(msg,user)
  end

  private



end




