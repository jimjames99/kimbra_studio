module Minisite

  class BaseController < ApplicationController

    skip_before_filter :authenticate_user!
    before_filter :load_email
    before_filter :set_by_tracking
    before_filter :set_cart_and_client_and_studio
    before_filter :setup_story

    layout 'minisite'

    private #===========================================================================

    # current navbar minisite menu
    # :collection, :charms, :chains, :about, :shopping_cart
    def navbar_active
      # reset in controller for active navbar menu item
      @navbar_active = :collection
    end

    # TODO - REMEMBER THIS! This logic is not multi-session safe. Meaning that if you flit from one
    # offer email to another, only the first offer email data is kept in the rails session. Unlikely
    # to be a problem in real life, but worth refactoring away some time.

    # TODO See TODO below.
    def load_email
      puts "SESSION: #{session.inspect}"
      @admin_customer_email = Admin::Customer::Email.find_by_tracking(params[:email_id]) if params[:email_id]
    end

    # TODO See TODO below.
    def set_by_tracking
      @admin_customer_offer = Admin::Customer::Offer.find_by_tracking(params[:id]) if params[:id]
      @admin_customer_email ||= @admin_customer_offer.email if @admin_customer_offer
    end

    # TODO This logic is tortured. Need to outline the different ways we get to this controller and set session vars accordingly.
    # 1. From session begun by offer email.
    # 2. From session begun by confirmation email offer status link.
    # 3. From bookmarks to any interior page.
    # 4. where else?!? don't forget combinations of the above.
    def set_cart_and_client_and_studio
      # Pull cart from incoming link; usually confirmation email order status link.
      if params[:cart]
        @cart                 = Shopping::Cart.find_by_tracking(params[:cart])
        @admin_customer_email = @cart.email
        @admin_customer_offer = nil
      end

      if (is_client?)
        # Pull cart from current session; usually normal shopping activity.
        if @cart.nil? && session[:cart_id]
          @cart = Shopping::Cart.find(session[:cart_id]) rescue nil
          @admin_customer_email = @cart.email if @cart
        end
        # Otherwise create new cart; we are starting a new shopping session.
        # Offer and email are already set.
        if @cart.nil?
          @cart             = Shopping::Cart.create(:email => @admin_customer_email)
          session[:cart_id] = @cart.id
        end
        session[:admin_customer_email_id] = @admin_customer_email.id
        @client                           = @admin_customer_email.my_studio_session.client
        session[:client_id]               ||= @client.id
        @studio                           = @admin_customer_email.my_studio_session.studio
        session[:studio_id]               ||= @studio.id
      elsif (is_studio?)
        # studio and admin should have @cart and @client nil
        @studio = current_user.studio
      else
        # studio and admin should have @cart and @client nil
        @studio = @admin_customer_email.my_studio_session.studio
      end
    end

  end

end