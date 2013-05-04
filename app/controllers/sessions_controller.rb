class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    puts "#{auth}"
    
   # session[:user_id] = user.id
    #redirect_to users, :notice => "Signed in!"

  end


  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end