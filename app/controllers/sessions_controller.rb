require 'net/http'

class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    puts "#{auth}"
    session[:user] = auth.info.name
    session[:uid] = auth.uid

    user = User.where(:uid => auth.uid).first 
    if (user.nil? || user.phone_number.nil? )
     redirect_to new_user_path,:notice => 'Sign up please!'
    else
      redirect_to user,:notice => 'Signed in!' 
    end


  end


  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end