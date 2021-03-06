class UsersController < ApplicationController

 def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def new
    @user = User.new

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

  def create
  
    auth = session[:user]
    n = params[:user][:phone_number]
    uid = session[:uid]

    @user = User.where(:phone_number => n).first

    if(@user.nil?)
      @user = User.new(:name => auth,:phone_number => n, :uid => uid)
    else
      @user.update_attributes(:name =>auth, :uid => uid)
      @user.save
    end
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Usuario criado com sucesso.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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

end