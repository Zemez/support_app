class HomeController < ApplicationController
  def index
    session[:times_here] ||= 0
    session[:times_here] += 1
    session[:switch] = session[:switch] ? false : true
  end
end
