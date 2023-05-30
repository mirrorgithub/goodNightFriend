class UserClockedIn < ApplicationRecord
	belongs_to :user
	validate :name_validator

	USER_ACTION_SLEEP = 1
	USER_ACTION_WAKE_UP = 2

	private

	def name_validator
		unless (action_id == USER_ACTION_SLEEP || action_id == USER_ACTION_WAKE_UP)
			errors.add(:action_id, message: "action_id invalid")
		end
	end

	# add user action_id check
end


=begin
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


about the column "action_id"
At first I would like to use the time to automatically distinguish whether user get up or go to sleep.
However, there are some reasons cause people would not sleep in the night such as work or take airplain.
I set the default value is "go to sleep" because people might feel tired before sleeping.
=end