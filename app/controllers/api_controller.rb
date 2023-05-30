class ApiController < ApplicationController
	include ConstHelper

	#some of the action need user login first, use before_action to check it
 	before_action :_check_login, except: [:user_login, :home] 

	def home
		render plain: "should be a landing page here"
	end

	def user_login
		#the user name is unique
		uu = User.find_by(name: params[:user_name])
		if uu
			session[:user_id] = uu.id #use the session value to authentication
			render json: {result: R_SUCCESS}
		else
			render json: {result: R_DATA_NOT_FOUND, reason: "user not found"}
		end
	end



	def set_clock_in
	end

	def follow_friend
	end

	def unfollow_friend
	end

	def sleep_record
	end

	private 

	def _check_login
		redirect_to root_path unless session[:user_id]
	end
end
