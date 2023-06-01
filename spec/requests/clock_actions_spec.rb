require 'rails_helper'

include ConstHelper

# rails generate rspec:integration clock_action
# bundle exec rspec spec/requests/clock_actions_spec.rb

RSpec.describe "ClockActions", type: :request do
	describe "GET /clock_actions" do
		before do
			User.create(name: "Ray")
		end
		
		it "test set clock in" do
			uu = User.find_by(name: "Ray")

			post "/api/set/clock_in/" 
			expect(response).to have_http_status(302) #User should login first, redirect

			post "/api/user/login/", params:{:user_name=>"Ray"}

			post "/api/set/clock_in/" #without params
			expect(response).to have_http_status(200)
			expect(UserClockedIn.all.count).to eql 1 #success

			post "/api/set/clock_in/", params:{:timezone=>"Ray"}
			expect(JSON.parse(response.body)["result"]).to eql R_PARAMS_ERROR # timezone error

			post "/api/set/clock_in/", params:{:timezone=>"Europe/London"}
			expect(UserClockedIn.all.count).to eql 2

			post "/api/set/clock_in/", params:{:action_id=>"3"}
			expect(JSON.parse(response.body)["result"]).to eql R_PARAMS_ERROR # action_id can only be 1 or 2

			post "/api/set/clock_in/", params:{:action_id=>"2"}
			expect(UserClockedIn.all.count).to eql 3
			expect(UserClockedIn.last.timezone).to eql "Europe/London"
			expect(UserClockedIn.last.city).to eql ""

			post "/api/set/clock_in/", params:{:action_id=>"1"}
			expect(UserClockedIn.all.count).to eql 4

			post "/api/set/clock_in/", params:{:clocked_in=>"2023-05-31 07:34:36", :city=>"Kaohsiung"}
			expect(UserClockedIn.all.count).to eql 5
			tempTime = UserClockedIn.last.clocked_in
			tempCity = UserClockedIn.last.city
			
			post "/api/set/clock_in/", params:{:clocked_in=>"2023-05-31 07:34:36", :timezone=>"UTC"}
			expect(tempTime).not_to eql UserClockedIn.last.clocked_in #because of time zone
			expect(tempCity).to eql UserClockedIn.last.city #test the city cache
			expect(JSON.parse(response.body)["clcok_in_record"].count).to eql 6
		end

		it "test get sleep record" do
			uRay = User.find_by(name: "Ray")
			uJohn = User.create(name: "John")

			post "/api/user/login/", params: {:user_name=>"Ray"}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			cutTime = Time.current

			post "/api/set/clock_in/", params:{:clocked_in=>cutTime.to_s, :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - 8.hours}", :city=>"Kaohsiung"}

			minusDay = 1.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay+ 1.minutes}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours + 1.minutes}", :city=>"Kaohsiung"}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}

			minusDay = 2.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}

			minusDay = 3.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}

			minusDay = 4.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			# t1 = Time.zone.parse(UserClockedIn.last.clocked_in.to_s).utc
			t1 = UserClockedIn.last.clocked_in
			cutTime.in_time_zone("Fiji")
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung", :timezone => "Fiji"}
			expect(t1 - UserClockedIn.last.clocked_in).to eql 8.hours.to_f
			

			minusDay = 7.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}
			
			minusDay = 8.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}

			post "/api/user/login/", params: {:user_name=>"John"}
			post "/api/follow/", params:{:friend_id=>uRay.id}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			# userClockedInData = UserFollowList.includes(:friend => [:user_clocked_in]).all
			# p "#{userClockedInData[0].friend.user_clocked_in.inspect}"
		end
	end
end
