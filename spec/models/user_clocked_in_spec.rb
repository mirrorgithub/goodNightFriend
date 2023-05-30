require 'rails_helper'
# rails generate rspec:model UserClockedIn
# bundle exec rspec spec/models/user_clocked_in_spec.rb
RSpec.describe UserClockedIn, type: :model do

  it "create user clocked in test" do
    u1name = "Ray"

    u1 = User.create(name: u1name)

    tempTime = Time.current
    
    # time zone function
    # https://thoughtbot.com/blog/its-about-time-zones
    usrClockIn1 = UserClockedIn.create(user_id: u1.id, clocked_in: tempTime, timezone: "#{Time.zone.name}")

    expect(usrClockIn1.user.name).to eql u1name

    time1 = "#{usrClockIn1.clocked_in}"
    Time.use_zone("Sydney") do
      usrClockIn2 = UserClockedIn.create(user_id: u1.id, clocked_in: tempTime, timezone: "#{Time.zone.name}")
      
      expect(time1).not_to eql "#{usrClockIn2.clocked_in}" #because of the time zone, they would not equal
      expect(usrClockIn1.clocked_in).to eql usrClockIn2.clocked_in #the value is equal
    end
  end
end