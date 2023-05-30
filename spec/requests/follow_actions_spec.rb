require 'rails_helper'

include ConstHelper

# bundle exec rspec spec/requests/follow_actions_spec.rb

RSpec.describe "FollowActions", type: :request do
	describe "GET /follow_actions" do
		before do
			User.create(name: "Ray")
			User.create(name: "John")
			post "/api/user/login/", params:{:user_name=>"Ray"}
		end

		it "test the follow action" do
			rayu = User.find_by(name: "Ray")
			johnu = User.find_by(name: "John")

			post '/api/follow/', params:{:friendss_id=>"Ray"}
			expect(response).to have_http_status(200)
			resultJson = JSON.parse(response.body)
			expect(resultJson["result"]).to eql R_PARAMS_ERROR

			post '/api/follow/', params:{:friend_id=>rayu.id}
			expect(JSON.parse(response.body)["result"]).to eql R_PARAMS_ERROR

			post '/api/follow/', params:{:friend_id=>rayu.id + 100}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_NOT_FOUND

			post '/api/follow/', params:{:friend_id=>"rayu.id + 100"}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_NOT_FOUND

			post '/api/follow/', params:{:friend_id=>johnu.id}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			post '/api/follow/', params:{:friend_id=>johnu.id}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_ALREADY_IN_DB



			delete '/api/follow/', params:{:friendss_id=>"Ray"}
			expect(response).to have_http_status(200)
			resultJson = JSON.parse(response.body)
			expect(resultJson["result"]).to eql R_PARAMS_ERROR

			delete '/api/follow/', params:{:friend_id=>rayu.id + 100}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_NOT_FOUND

			delete '/api/follow/', params:{:friend_id=>"rayu.id + 100"}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_NOT_FOUND

			delete '/api/follow/', params:{:friend_id=>rayu.id}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_NOT_FOUND

			delete '/api/follow/', params:{:friend_id=>johnu.id}
			expect(JSON.parse(response.body)["result"]).to eql R_SUCCESS

			delete '/api/follow/', params:{:friend_id=>johnu.id}
			expect(JSON.parse(response.body)["result"]).to eql R_DATA_NOT_FOUND
		end
	end
end
