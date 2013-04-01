#encoding: utf-8
class Dream < ActiveRecord::Base
  attr_accessible :dream_name,:cost,:time,:parcela

  belongs_to :user 
end