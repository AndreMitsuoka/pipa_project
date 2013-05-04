class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    puts "#{auth}"
    session[:user] = auth.info.name
    session[:uid] = auth.uid
    redirect_to new_user_path,:notice => 'Signed in!'

  end


  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end