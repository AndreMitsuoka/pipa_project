class CreateAgendas < ActiveRecord::Migration
	def self.up
		create_table :agendas do |t|
			t.string :name
			t.datetime :date
			t.integer :user_id

			t.timestamp
		end
	end

	def self.down
		drop_table :agendas
	end
end