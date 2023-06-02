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
			uSusan = User.create(name: "Susan")

			timeRangeWeFetched = 7.days
			threshouldTime = (Time.current - timeRangeWeFetched)
			threshouldTimePeopleView = threshouldTime.strftime("%Y%m%d").to_i
			# p "#{threshouldTimePeopleView}"

			#===== the data of Ray
			post "/api/user/login/", params: {:user_name=>"Ray"}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			cutTime = Time.current
			raySleepTime = 0
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
			
			minusDay = timeRangeWeFetched - 1.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}

			minusDay = timeRangeWeFetched
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"}
			
			minusDay = timeRangeWeFetched + 1.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2} #this record would not be counted in
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 8.hours}", :city=>"Kaohsiung"} #this record would not be counted in
			#===== the data of Ray

			#===== the data of Susan
			post "/api/user/login/", params: {:user_name=>"Susan"}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			cutTime = Time.current
			post "/api/set/clock_in/", params:{:clocked_in=>cutTime.to_s, :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - 7.hours}", :city=>"Kaohsiung"}

			minusDay = 1.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay+ 1.minutes}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 7.hours + 1.minutes}", :city=>"Kaohsiung"}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 7.hours}", :city=>"Kaohsiung"}

			minusDay = timeRangeWeFetched - 1.days
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2}
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 7.hours}", :city=>"Kaohsiung"}
			
			minusDay = timeRangeWeFetched
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay}", :city=>"Kaohsiung", :action_id=>2} #this record would not be counted in
			post "/api/set/clock_in/", params:{:clocked_in=>"#{cutTime - minusDay - 7.hours}", :city=>"Kaohsiung"} #this record would not be counted in
			#===== the data of Susan

			post "/api/user/login/", params: {:user_name=>"John"}
			post "/api/follow/", params:{:friend_id=>uRay.id}
			post "/api/follow/", params:{:friend_id=>uSusan.id}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			sleepObj = {"sleep_time": []}
			UserFollowList.eager_load(:friend => [:user_clocked_in]).where(user_id: uJohn.id).where('clocked_in >= ?', (threshouldTime - 1.days).beginning_of_day).order(:clocked_in).each do |uFlo|
				tempu = uFlo.friend.user_clocked_in
				# expect(tempu.count).to eql 18 + ((cutTime - timeRangeWeFetched + 1.days - 8.hours) < (Time.current - timeRangeWeFetched).beginning_of_day ? 1 : 0) if uFlo.friend_id == uRay.id
				# expect(tempu.count).to eql 10 + ((cutTime - timeRangeWeFetched + 1.days - 7.hours) < (Time.current - timeRangeWeFetched).beginning_of_day ? 1 : 0) if uFlo.friend_id == uSusan.id
				
				sleepObj[uFlo.friend_id] = {"friend_name": uFlo.friend.name, "go_to_bed_time": "-", "sleep_city": ""}
				tempu.each do |clockedObj|
					curObjTime = Time.parse(clockedObj.clocked_in.to_s).in_time_zone(clockedObj.timezone)
					next if curObjTime.strftime("%Y%m%d").to_i < threshouldTimePeopleView

					# if there are more than one sleep time came out continuously, we would only use the last one
					if clockedObj.action_id == UserClockedIn::USER_ACTION_SLEEP
						sleepObj[uFlo.friend_id][:go_to_bed_time] = Time.parse(clockedObj.clocked_in.to_s)
						sleepObj[uFlo.friend_id][:sleep_city] = clockedObj.city
					end

					# if there are more than one wake up time came out continuously, we would only use the first one
					if clockedObj.action_id == UserClockedIn::USER_ACTION_WAKE_UP && sleepObj[uFlo.friend_id][:go_to_bed_time] != "-"
						sleepObj[:sleep_time] << {"sleep_time": clockedObj.clocked_in - sleepObj[uFlo.friend_id][:go_to_bed_time],
							"sleep_time_str": "#{'%.2f' % ((clockedObj.clocked_in - sleepObj[uFlo.friend_id][:go_to_bed_time])/3600)} hours",
							"sleep_city": sleepObj[uFlo.friend_id][:sleep_city],
							"wake_city": clockedObj.city,
							"friend_name": uFlo.friend.name,
							"sleep_date": sleepObj[uFlo.friend_id][:go_to_bed_time].strftime("%Y%m%d").to_i}
						sleepObj[uFlo.friend_id][:go_to_bed_time] = "-"
					end
				end
			end
			
			sleepObj = sleepObj[:sleep_time].sort { |v1, v2| [v2[:sleep_time], v2[:sleep_date]] <=> [v1[:sleep_time], v1[:sleep_date]] }

			post "/api/sleep/record/", params: {:userTime=>"====="}
			expect(JSON.parse(response.body)["result"]).to eql R_PARAMS_ERROR
			
			post "/api/sleep/record/", params: {:userTime=>Time.current.strftime("%Y-%m-%d %H:%M:%S")}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS
			expect(JSON.parse(response.body)["returnObj"][0]["friend_name"]).to eql sleepObj[0][:friend_name]
			expect(JSON.parse(response.body)["returnObj"][0]["sleep_time"]).to eql sleepObj[0][:sleep_time]

			post "/api/user/login/", params: {:user_name=>"Ray"}
			post "/api/sleep/record/", params: {:userTime=>Time.current.strftime("%Y-%m-%d %H:%M:%S")}
			expect(JSON.parse(response.body)["returnObj"].count).to eql 0 #ray follow no person. get temp data in returnObj.
		end
	end
end
