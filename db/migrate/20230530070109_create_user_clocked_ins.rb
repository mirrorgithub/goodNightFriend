class CreateUserClockedIns < ActiveRecord::Migration[6.1]
	def change
		create_table :user_clocked_ins do |t|
			t.integer :user_id, null: false
			t.datetime :clocked_in, null: false
			t.string :timezone, null: false
			t.column :action_id, 'tinyint unsigned', default: 1 #1 for go to bed, 2 for wake up
			t.string :city, default: ""
			t.timestamps
		end
	end
end

=begin
about the column "action_id"
At first I would like to use the time to automatically distinguish whether user get up or go to sleep.
However, there are some reasons cause people would not sleep in the night such as work or take airplain.
I set the default value is "go to sleep" because people might feel tired before sleeping.
=end