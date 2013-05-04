require 'net/http'

class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    puts "#{auth}"
    session[:user] = auth.info.name
    session[:uid] = auth.uid
    session[:fb_id] = auth.extra.raw_info.id

                       id = '474083902612604'
                        app_id='c727aa34975302cc533d5021a1bfe61c'
                        
                        url = URI.parse('http://www.facebook.com/oauth/access_token?client_id='+id+'&client_secret='+app_id+'&grant_type=client_credentials')
                        #url = URI.parse('http://www.google.com')
                        req = Net::HTTP::Get.new(url.path)
                        res = Net::HTTP.start(url.host, 3000) {|http|
                         http.request(req)
                        }
                        puts "\n#{res.code}\n"

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