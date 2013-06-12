#encoding: utf-8
class User < ActiveRecord::Base

  attr_accessible :phone_number,:name,:number_dreams, :uid

  validates_uniqueness_of :phone_number

  has_many :dreams ,:dependent => :destroy
  has_many :bills , :dependent => :destroy
  has_many :agendas,:dependent => :destroy



  def self.find_for_user(msg)
    #find for phone_number
    begin 
      @user = User.where(:phone_number => msg.sender).first

      unless @user
          @user = User.create(:phone_number => msg.sender)
      end

    rescue Exception => e  
        puts e.message  
        puts e.backtrace.inspect  
    end

    Sms.msg_interpretation(msg,@user)
  end
=begin 
          if @user.save
            #log.debug 'object saved correctly'
          else
            log.debug @user.errors.full_messages
            puts "#{@user.errors.full_messages}"
          end
=end       #  puts " #{sav} #{@user} #{@user.phone_number}\n\n"
end




