class UsersController < ApplicationController

 def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def create_modem()
    begin 
      $GSM = Gsm::Modem.new  #cria o Modem, mas deixa a sessão inativa
    rescue 
      puts "Error in initializers - No Modem Could be found\n"
    end
     @modem =  Modem.new($GSM)
  end
end