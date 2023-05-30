require 'rails_helper'
# rails generate rspec:model UserFollowList
# bundle exec rspec spec/models/user_follow_list_spec.rb
RSpec.describe UserFollowList, type: :model do
  
  # to test the connection between UserFollowList and User.
  it "create user follow list test" do
    u1name = "Ray"
    u2name = "John"

    u1 = User.create(name: u1name)
    u2 = User.create(name: u2name)
    uFollowList = UserFollowList.create(user_id: u1.id, friend_id: u2.id)

    # alternative way
    # ufl.user = u1
    # ufl.friend = u2
    # ufl.save

    expect(uFollowList.user.name).to eql u1name
    expect(uFollowList.friend.name).to eql u2name
  end
end
