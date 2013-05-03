#encoding: utf-8
class User < ActiveRecord::Base
  attr_accessible :phone_number,:name,:number_dreams

  has_many :dreams
  has_many :bills


  def self.find_for_user(msg)

    #find for phone_number
    @user = User.where(:phone_number => msg.sender).first  

    unless @user
      @user = User.create(  :phone_number => msg.sender)
    end

    Sms.msg_interpretation(msg,@user)
  end

  private



end




