#encoding: utf-8
class User < ActiveRecord::Base

  attr_accessible :phone_number,:name,:number_dreams,:uid

  validates_uniqueness_of :phone_number,:uid

  has_many :dreams ,:dependent => :destroy
  has_many :bills , :dependent => :destroy
  has_many :agendas,:dependent => :destroy



  def self.find_for_user(msg)
    #fazer uma nova tread? 

    #find for phone_number
    @user = User.where(:phone_number => msg.sender).first  

    unless @user
      @user = User.create(:phone_number => msg.sender)
    end
    
    Tread.new {
      Thread.current[:name] = "Handle sms"
      Sms.msg_interpretation(msg,@user)
    }

  end

  private



end




