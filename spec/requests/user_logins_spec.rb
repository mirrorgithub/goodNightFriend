require 'rails_helper'

# rails generate rspec:integration user_login
# bundle exec rspec spec/requests/user_logins_spec.rb

include ConstHelper

RSpec.describe "UserLogins", type: :request do
	describe "GET /user_logins" do
		it "works! (now write some real specs)" do
			User.create(name: "Ray")

			post "/api/user/login/", params: {:user_name=>"DummyRay"}
			expect(response).to have_http_status(200)
			resultJson = JSON.parse(response.body)
			expect(resultJson["result"]).to eql R_DATA_NOT_FOUND

			post "/api/user/login/", params: {:user_name=>"Ray"}
			resultJson = JSON.parse(response.body)
			expect(resultJson["result"]).to eql R_SUCCESS
		end
	end
end
