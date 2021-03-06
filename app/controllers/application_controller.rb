class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, :notification, :orders
  #check_authorization :unless => :devise_controller?
      rescue_from ActiveRecord::RecordNotFound do
    flash[:warning] = 'Resource not found.'
    redirect_back_or root_path
  end

  def redirect_back_or(path)
    redirect_to request.referer || path
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:warning] = exception.message
    redirect_back_or root_path

  end

  def check_admin_role
    return if current_user.role?(:admin)
    flash[:warning] = "You need to be an admin to access this part of the application"
    redirect_to root_path
  end

  def active_admin_controller?
    self.is_a? ActiveAdmin::BaseController
  end

  def notification
    @notification = current_user.mailbox.inbox(unread: true) if current_user
  end

  def orders
    puts current_user
    @unapproved_orders = Request.where(:approver_id => current_user.id,  :status => "Open") if current_user
  end

end
