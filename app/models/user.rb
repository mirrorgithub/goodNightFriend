class User < ApplicationRecord
	has_many :user_follow_lists
	has_many :user_clocked_in
	has_many :following_connections, foreign_key: "friend_id", class_name: "UserFollowList"
end
