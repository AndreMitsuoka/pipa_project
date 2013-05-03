#encoding: utf-8
class Dream < ActiveRecord::Base
  attr_accessible :dream_name,:cost,:next_week,:weekly_save
  attr_accessible :value_per_week,:saved,:date

  belongs_to :user 
end