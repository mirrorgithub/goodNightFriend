class CreateUserClockedIns < ActiveRecord::Migration[6.1]
	def change
		create_table :user_clocked_ins do |t|
			t.integer :user_id, null: false
			t.datetime :clocked_in, null: false
			t.string :timezone, null: false
			t.string :city, default: ""
			t.timestamps
		end
	end
end
