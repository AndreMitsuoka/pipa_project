#encoding: utf-8
class Bill < ActiveRecord::Base
  attr_accessible :date,:name

  belongs_to :user
   #$GSM.send_sms!('+551581144047','I am working dude!')
end

