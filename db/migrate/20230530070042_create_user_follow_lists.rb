class CreateUserFollowLists < ActiveRecord::Migration[6.1]
	def change
		create_table :user_follow_lists do |t|
			t.integer :user_id, null: false
			t.references :friend, foreign_key: { to_table: :users }
			t.timestamps
		end
	end
end
