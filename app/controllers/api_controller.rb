class ApiController < ApplicationController
	include ConstHelper
	include ApiHelper

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

	# user use this api to set clock in
	# user can 
	# 1. call this api without any params
	# 2. give some params, we have 4 params in this api, the rest field would use the default value
	#  params=>
	#       (string)timezone: system time zone, <== if user give the wrong timezone value, we would tell user the time zone is illegal.
	# 		(string)city: empty string, <== we might wanna friends know which city i am living.
	# 		(string)clocked_in: Time.current, <== user can use the specific time the format is "2023-05-31 07:34:36"
	# 		(int)action_id: 1, <== which means go to sleep, user can only set 1 or 2 in action_id
	# 
	# there are only 2 situations would show error, 
	# The time zone illegal or save data to UserClockedIn failed.
	# both of the situation would return R_PARAMS_ERROR in result code field.
	#  return=>
	# 		{result: R_PARAMS_ERROR, reason: "time zone error"}
	# 		{result: R_PARAMS_ERROR, reason: "insert data error"}
	# 		{result: R_SUCCESS, clcok_in_record: [{clocked_in: ,timezone: ,user_action: ,city: }, {clocked_in: ,timezone: ,user_action: ,city: }, ... ]}
	def set_clock_in
		tempTimeZone = "UTC"
		tempTimeZone = Rails.cache.read("timezone_#{session[:user_id]}") if Rails.cache.read("timezone_#{session[:user_id]}")
		tempTimeZone = params[:timezone] if (params[:timezone].present?)

		tempCity = "" #maybe we would like to know where is our friend
		tempCity = Rails.cache.read("city_#{session[:user_id]}") if Rails.cache.read("city_#{session[:user_id]}") #use the cache that user would not choose city every time
		tempCity = params[:city] if (params[:city].present?)
		Rails.cache.write("city_#{session[:user_id]}", tempCity, expires_in: cacheExpire) if tempCity != ""

		begin
			Time.zone = tempTimeZone
			# save the data in cache so user don't have to choose time zone every time.
			# also, we would show the current timezone for this user in frontend to let user know which timezone they used.
			# the cacheExpire is in application_controller
			Rails.cache.write("timezone_#{session[:user_id]}", tempTimeZone, expires_in: cacheExpire)
		rescue ArgumentError => expect
			return render json: {result: R_PARAMS_ERROR, reason: "time zone error"}
		end

		userTimeZone = Time.zone.name
		createParams = {user_id: session[:user_id], city: tempCity, timezone: userTimeZone}
		createParams[:clocked_in] = (params[:clocked_in].present?) ? Time.zone.parse(params[:clocked_in]).utc : Time.current.utc
		createParams[:action_id] = params[:action_id] if (params[:action_id].present?) # I don't check the value of action_id. Leave it to validate function of UserClockedIn.

		# time zone function
		# https://thoughtbot.com/blog/its-about-time-zones
		usrClockIn1 = UserClockedIn.create(createParams)
		userClockedInData = UserClockedIn.where(user_id: session[:user_id]).order(created_at: :desc).map{ |ucData|
			{clocked_in: Time.zone.parse(ucData.clocked_in.strftime("%Y-%m-%d %H:%M:%S")).in_time_zone(ucData.timezone).utc.strftime("%Y-%m-%d %H:%M:%S"),
				timezone: ucData.timezone,
				user_action: user_action_str(ucData.action_id), 
				city: ucData.city}
		}
		
		resultObj = usrClockIn1.save == false ? {result: R_PARAMS_ERROR, reason: "insert data error"} : {result: R_SUCCESS, clcok_in_record: userClockedInData}

		render json: resultObj
	end

	# use this api to follow friend
	# the timing of this api return error would be
	# 1. user doesn't give the friend id
	# 2. we cannot find user via friend id
	# 3. the friend_id is the same as user id
	# 4. user had followed friend
	#  params=> 
	# 		(int)friend_id
	#  return=>
	# 		{result: R_PARAMS_ERROR, reason: "require friend_id"}
	# 		{result: R_PARAMS_ERROR, reason: "user_id cannot equal to friend_id"}
	# 		{result: R_DATA_NOT_FOUND, reason: "friend not found"}
	# 		{result: R_DATA_ALREADY_IN_DB, reason: "you had already followed your friend"}
	# 		{result: R_SUCCESS}
	def follow_friend
		return render json: {result: R_PARAMS_ERROR, reason: "require friend_id"} if !(params[:friend_id].present?)

		# user cannot follow itself
		return render json: {result: R_PARAMS_ERROR, reason: "user_id cannot equal to friend_id"} if session[:user_id] == params[:friend_id].to_i 
		uu = User.find_by(id: params[:friend_id])
		
		return render json: {result: R_DATA_NOT_FOUND, reason: "friend not found"} if !uu
		return render json: {result: R_DATA_ALREADY_IN_DB, reason: "you had already followed your friend"} if UserFollowList.find_by(user_id: session[:user_id], friend: params[:friend_id])

		UserFollowList.create(user_id: session[:user_id], friend_id: params[:friend_id])
		render json: {result: R_SUCCESS}
	end

	# use this api to unfollow friend
	# the timing of this api return error would be
	# 1. user doesn't give the friend id
	# 2. we cannot find the data in follow list
	#  params=> 
	# 		(int)friend_id
	#  return=>
	# 		{result: R_PARAMS_ERROR, reason: "require friend_id"}
	# 		{result: R_DATA_NOT_FOUND, reason: "you have not follow this friend"}
	# 		{result: R_SUCCESS}
	def unfollow_friend
		return render json: {result: R_PARAMS_ERROR, reason: "require friend_id"} if !(params[:friend_id].present?)

		uFollowList = UserFollowList.find_by(user_id: session[:user_id], friend_id: params[:friend_id])
		return render json: {result: R_DATA_NOT_FOUND, reason: "you have not follow this friend"} if !uFollowList

		uFollowList.destroy
		render json: {result: R_SUCCESS}
	end

	# the frontend need to give the time because of the time zone
	# we might in the timezone +12 place and want to know the friend whom in timezone -12
	# the time format is "%Y-%m-%d %H:%M:%S"
	#  params=> 
	# 		(int)friend_id
	#  return=>
	# 		{result: R_PARAMS_ERROR, reason: "time format error"}
	# 		{result: R_SUCCESS, returnObj: [{"sleep_time": (int) how many seconds this user sleep, use it for sorting,
	# 										"sleep_time_str": (string) such as "7.52 hours",
	# 										"sleep_city": (string)in which user go to bed,
	# 										"wake_city": (string)in which user get up,
	# 										"friend_name": (string)friend_name,
	# 										"sleep_date": (int) format is "%Y%m%d" the date user go to bed}, ... ]
	def sleep_record
		
		begin
			threshouldTime = (Time.parse(params[:userTime]) - 7.days).beginning_of_day
		rescue ArgumentError => expect
			return render json: {result: R_PARAMS_ERROR, reason: "time format error"}
		end

		threshouldTimePeopleView = threshouldTime.strftime("%Y%m%d").to_i
		sleepObj = {"sleep_time": []}
		# use eager_load to avoid the N+1 problem and we can use where to set the condition of "clocked_in" 
		# we fetch one more day before(threshouldTime - 1.days) because the difference between timezone and people view
		UserFollowList.eager_load(:friend => [:user_clocked_in]).where(user_id: session[:user_id]).where('clocked_in >= ?', (threshouldTime - 1.days).beginning_of_day).order(:clocked_in).each do |uFlo|
			tempu = uFlo.friend.user_clocked_in
			
			sleepObj[uFlo.friend_id] = {"friend_name": uFlo.friend.name, "go_to_bed_time": "-", "sleep_city": ""}
			tempu.each do |clockedObj|

				# we might in the timezone +12 place and want to know the friend whom in timezone -12
				# In this situation we use the threshouldTimePeopleView to check the condition.
				curObjTime = Time.parse(clockedObj.clocked_in.to_s).in_time_zone(clockedObj.timezone)
				next if curObjTime.strftime("%Y%m%d").to_i < threshouldTimePeopleView

				# if there are more than one sleep time came out continuously, we would only use the last one
				if clockedObj.action_id == UserClockedIn::USER_ACTION_SLEEP
					sleepObj[uFlo.friend_id][:go_to_bed_time] = Time.parse(clockedObj.clocked_in.to_s)
				end

				# if there are more than one wake up time came out continuously, we would only use the first one
				if clockedObj.action_id == UserClockedIn::USER_ACTION_WAKE_UP && sleepObj[uFlo.friend_id][:go_to_bed_time] != "-"
					# since the value is save in utc + 0 timezone, we can calculate it.
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

		returnObj = sleepObj[:sleep_time].sort { |v1, v2| [v2[:sleep_time], v2[:sleep_date]] <=> [v1[:sleep_time], v1[:sleep_date]] }

		render json: {result: R_SUCCESS, returnObj: returnObj}
	end

	private 

	def _check_login
		redirect_to root_path unless session[:user_id]
	end
end
