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
		return render json: {result: R_PARAMS_ERROR, reason: "require friend_id"} if !(params[:friend_id].present?)
		return render json: {result: R_PARAMS_ERROR, reason: "user_id cannot equal to friend_id"} if session[:user_id] == params[:friend_id].to_i
		uu = User.find_by(id: params[:friend_id])
		
		return render json: {result: R_DATA_NOT_FOUND, reason: "friend not found"} if !uu
		return render json: {result: R_DATA_ALREADY_IN_DB, reason: "you had already followed your friend"} if UserFollowList.find_by(user_id: session[:user_id], friend: params[:friend_id])

		UserFollowList.create(user_id: session[:user_id], friend_id: params[:friend_id])
		render json: {result: R_SUCCESS}
	end

	def unfollow_friend
		return render json: {result: R_PARAMS_ERROR, reason: "require friend_id"} if !(params[:friend_id].present?)
		uu = User.find_by(id: params[:friend_id])
		
		return render json: {result: R_DATA_NOT_FOUND, reason: "friend not found"} if !uu

		uFollowList = UserFollowList.find_by(user_id: session[:user_id], friend_id: params[:friend_id])
		return render json: {result: R_DATA_NOT_FOUND, reason: "you have not follow this friend"} if !uFollowList

		uFollowList.destroy
		render json: {result: R_SUCCESS}
	end

	def sleep_record
	end

	private 

	def _check_login
		redirect_to root_path unless session[:user_id]
	end
end
