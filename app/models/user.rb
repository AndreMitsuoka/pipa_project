#encoding: utf-8
class User < ActiveRecord::Base
  attr_accessible :phone_number,:name,:number_dreams,:incoming , :outgoing

  has_many :dreams

  def self.find_for_user(msg)
      puts "Hello METHOD \n"

      #find for phone_number
      user = User.where(:phone_number => msg.sender).first  

      puts "User msg in @incoming: #{msg.text}\n"
      var_msg = words_from_msg(msg.text)
      puts "\n#{var_msg}\n"


      #find the user in database, if it is the first time, save his number
      unless user
        user = User.create(  :phone_number => msg.sender                           )
      end
      return user
    end
end

def words_from_msg(string)
  #puts the msg as a array
  string.downcase.scan(/[\w']+/)
end


