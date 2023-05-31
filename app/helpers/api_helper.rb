module ApiHelper
	def user_action_str(action_code)
		action_code == 1 ? "go to sleep" : "wake up"
	end
end
