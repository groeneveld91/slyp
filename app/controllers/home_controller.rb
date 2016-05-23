class HomeController < ApplicationController
  helper_method :resource_name, :resource, :devise_mapping

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def index
    return unless current_user
    redirect_to "/feed"
  end

  def feed
    authenticate_user!
    @user = current_user
  end
end
