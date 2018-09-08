class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expirarion, only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_path
    else
      flash.now[:danger] = "Email address not found"
      render "new"
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.update_attribute(:reset_digest, nil)
      log_in(@user)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render "edit"
    end
  end

  private
    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_path
      end
    end

    def check_expirarion
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # => "$2a$10$bLWbfHv0vuE84hJzletmM.f7BQYfkcsFaLrHgLf1wQ25CyQHr9so2"
    # => "$2a$10$CTZFVMJAg2epwUqey42bbeABRXBGFRKlOZkwtX0vw4hm2aV4tMZlC"


end
