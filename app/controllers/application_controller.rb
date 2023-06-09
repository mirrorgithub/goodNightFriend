class ApplicationController < ActionController::Base
	rescue_from StandardError, :with => :exceptionCatch

	protected
	
	def cacheExpire
		7.days
	end

	private 

	def exceptionCatch(err)
		my_logger = Logger.new("#{Rails.root}/log/exception.log")
		my_logger.info err.backtrace[0..50].join("\n")
		my_logger.info err.message
	end
end
