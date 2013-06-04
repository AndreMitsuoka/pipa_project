class CreateDreams < ActiveRecord::Migration
	def self.up
		create_table :dreams do |t|
			t.string :dream_name
			t.float :cost
			t.float :value_per_week
			t.float :saved
			t.float :weekly_saved
			t.datetime :date
			t.datetime :next_week
			t.integer :user_id


			t.timestamp
		end
	end

	def self.down
		drop_table :dreams
	end
end