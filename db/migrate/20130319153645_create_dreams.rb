class CreateDreams < ActiveRecord::Migration
	def self.up
		create_table :dreams do |t|
			t.float :dream_cost
			t.integer :time
			t.float :parcela
			t.timestamp
		end
	end

	def self.down
		drop_table :dreams
	end
end