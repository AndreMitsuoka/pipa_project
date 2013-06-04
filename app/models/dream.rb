#encoding: utf-8
class Dream < ActiveRecord::Base
  attr_accessible :dream_name,:cost,:next_week,:weekly_saved
  attr_accessible :value_per_week,:saved,:date, :updated_at

  belongs_to :user 
end