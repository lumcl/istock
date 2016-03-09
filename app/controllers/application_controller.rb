class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  #config.web_console.whitelisted_ips = '172.91.132.0/16'

  def text_area_to_array(text_area)
    array = Array.new
    buf = text_area.split("\n")
    buf.each do |s|
      array << s.strip.gsub("\r","")
    end
    array
  end

end
