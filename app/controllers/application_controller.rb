class ApplicationController < ActionController::Base

  protect_from_forgery
  before_filter :log_session
  before_filter :authenticate_user!
  before_filter :load_my_studio

  layout 'application'

  # override devise url reference
  #  based on user's current roles
  def after_sign_in_path_for(resource)
    u = stored_location_for(resource)
    u2 = signed_in_root_path(resource)
    puts "u=>#{u}\nu2=>#{u2}"
    u || u2
    #u = if resource.acadia_staff?
    #      admin_merchant_accounts_url
    #    elsif resource.merchant?
    #      if resource.respond_to?(:account)
    #        if resource.account.nil?
    #          new_merchant_account_url
    #        else
    #          merchant_account_daily_deals_url(resource.account)
    #        end
    #
    #      else
    #
    #      end
    #
    #    else
    #      nil
    #    end
    #u || root_url
  end

  def is_admin?
    defined?(current_user) and current_user and current_user.admin?
  end

  def is_studio?
    defined?(current_user) and current_user and current_user.studio?
  end

  def is_client?
    (is_admin? or is_studio?) ? false : true
  end

  def require_user
    redirect_to login_url and return if logged_out?
  end

  def logged_out?
    !current_user
  end

  def setup_story
    @story, @storyline = Story.setup(request, controller_name, action_name, @client, @studio, is_client?)
  end

  private #=========================================================================

  def authenticate_admin!
    current_user && current_user.admin?
  end

  def do_not_cache
    response.headers['Cache-Control'] = 'no-chache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def load_my_studio
    @my_studio = current_user.studio if current_user
  end

  def log_session
    puts "RAILS SESSION: #{session.inspect}"
    logger.info "RAILS SESSION: #{session.inspect}"
  end

end