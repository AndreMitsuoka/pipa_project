class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.string :phone_number
			t.string :name
			t.integer :number_dreams
			t.integer :uid
			t.integer :fb_id
		
			t.timestamp
		end
	end

	def self.down
		drop_table :users
	end
end