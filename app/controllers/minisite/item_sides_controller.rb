class Minisite::ItemSidesController < InheritedResources::Base

  skip_before_filter :authenticate_user!
  before_filter :set_by_tracking
  before_filter :set_cart_and_client_and_studio
  before_filter :setup_story

  layout 'minisite'

  def update
    portrait_attrs = params[:admin_customer_item_side].delete(:portrait_attributes)
    @portrait = MyStudio::Portrait.find(portrait_attrs[:id])
    params[:admin_customer_item_side][:portrait] = @portrait
    success = @item_side.update_attributes(params[:admin_customer_item_side])
    if success
      @storyline.describe 'Saved item side.'
      @offer.update_front_side(@item_side.item)
      success = @offer.save
    end
    respond_to do |format|
      if success
        format.html { redirect_to minisite_offer_url(@item_side.item.offer), notice: 'Item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @item_side.errors, status: :unprocessable_entity }
      end
    end
  end

          # get /minisite/offers/tracking/portrait
  def portrait
    @storyline.describe 'Selecting a new portrait.'
    @portrait = MyStudio::Portrait.find(params[:portrait_id]) rescue nil
  end

  def stock
    @storyline.describe 'Selecting stock portrait.'
    @portrait = MyStudio::Portrait.find(params[:item_side_id]) rescue nil
    render :portrait
  end

  def edit
    @storyline.describe 'Editing item side.'
  end

  private #==========================================================================

  def set_by_tracking
    @item_side = Admin::Customer::ItemSide.find(params[:id]) if params[:id]
    @offer = Admin::Customer::Offer.find_by_tracking(params[:offer_id]) if params[:offer_id]
    @offer ||= @item_side.item.offer
    @email ||= @offer.email if @offer
  end

  def set_cart_and_client_and_studio
    if session[:cart_id]
      @cart = Shopping::Cart.find(session[:cart_id]) rescue nil
    end
    if @cart.nil?
      @cart             = Shopping::Cart.create(:email => @email)
      session[:cart_id] = @cart.id
    end
    session[:admin_customer_email_id] = @email.id
    @client                           = @email.my_studio_session.client
    session[:client_id]               ||= @client.id
    @studio                           = @email.my_studio_session.studio
    session[:studio_id]               ||= @studio.id
    @admin_customer_email             = @email
    @admin_customer_offer             = @offer
  end

end