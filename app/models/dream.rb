#encoding: utf-8
class Dream < ActiveRecord::Base
  attr_accessible :dream_name,:cost,:weeks,:value_per_week,:saved

  belongs_to :user 
end