class Admin::Customer::OffersController < ApplicationController

  before_filter :load_email
  before_filter :set_by_tracking

  # GET /admin/customer/offers
  # GET /admin/customer/offers.json
  def index
    set                    = if @email
                               @email.offers
                             else
                               Admin::Customer::Offer.where(:tracking => params[:email_id]).all
                             end
    @record_count          = set.count
    @admin_customer_offers = set.page(params[:page])


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_customer_offers }
    end
  end

  # GET /admin/customer/offers/1t7t7rye
  # GET /admin/customer/offers/1t7t7rye.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_customer_offer }
    end
  end

  # GET /admin/customer/offers/new
  # GET /admin/customer/offers/new.json
  def new
    @admin_customer_offer = Admin::Customer::Offer.new(:email => @email)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_customer_offer }
    end
  end

  # GET /admin/customer/offers/1t7t7rye/edit
  def edit

  end

  # POST /admin/customer/offers
  # POST /admin/customer/offers.json
  def create
    @admin_customer_offer       = Admin::Customer::Offer.new(params[:admin_customer_offer])
    @admin_customer_offer.email = @email

    result = @admin_customer_offer.save
    if (result)
      @admin_customer_offer.reassemble
    end

    respond_to do |format|
      if result
        format.html { redirect_to admin_customer_email_offer_url(@email, @admin_customer_offer), notice: 'Offer was successfully created.' }
        format.json { render json: admin_customer_email_offer_url(@email, @admin_customer_offer), status: :created, location: @admin_customer_offer }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_customer_offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/customer/offers/1t7t7rye
  # PUT /admin/customer/offers/1t7t7rye.json
  def update
    @admin_customer_offer.email = @email

    generate_offer = true if @admin_customer_offer.piece_id != params[:admin_customer_offer][:piece_id]
    generate_offer = true if params[:admin_customer_offer][:portrait_id]

    result = @admin_customer_offer.update_attributes(params[:admin_customer_offer])

    if result and generate_offer
      # send this to the worker to generate a new offer
      #   using the new kimbra piece
      @admin_customer_offer.reassemble
    end

    respond_to do |format|
      if result
        format.html { redirect_to admin_customer_email_offer_url(@email, @admin_customer_offer), notice: 'Offer was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_customer_offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/customer/offers/1t7t7rye
          # DELETE /admin/customer/offers/1t7t7rye.json
  def destroy
    @admin_customer_offer.destroy
    respond_to do |format|
      format.html { redirect_to admin_customer_offers_url }
      format.json { head :ok }
    end
  end

  private #===========================================================================

  def load_email
    @email = Admin::Customer::Email.find_by_tracking(params[:email_id]) if params[:email_id]
  end

  def set_by_tracking
    @admin_customer_offer = Admin::Customer::Offer.find_by_tracking(params[:id]) if params[:id]
  end

end