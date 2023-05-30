class UserFollowList < ApplicationRecord
	belongs_to :user
	belongs_to :friend, class_name: "User"

	validate :ids_validator

	private

	def ids_validator
		if (user_id == friend_id)
			errors.add(:ids, message: "user_id cannot equal to friend_id")
		end
	end
end


=begin
class CreateUserFollowLists < ActiveRecord::Migration[6.1]
	def change
		create_table :user_follow_lists do |t|
			t.integer :user_id, null: false
			t.references :friend, foreign_key: { to_table: :users }
			t.timestamps
		end
	end
end
=end