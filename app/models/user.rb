class User < ApplicationRecord
	has_many :user_follow_lists
	has_many :user_clocked_in
	has_many :following_connections, foreign_key: "friend_id", class_name: "UserFollowList"
end


=begin
class CreateUsers < ActiveRecord::Migration[6.1]
	def change
		create_table :users do |t|
			t.string :name#, unique: true
			t.timestamps
		end

		add_index :users, :name, unique: true
	end
end
=end