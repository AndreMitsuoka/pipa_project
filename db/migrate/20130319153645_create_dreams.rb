class CreateDreams < ActiveRecord::Migration
	def self.up
		create_table :dreams do |t|
			t.string :dream_name
			t.float :cost
			t.integer :time
			t.float :parcela
			t.float :saved
			t.integer :user_id
			t.timestamp
		end
	end

	def self.down
		drop_table :dreams
	end
end