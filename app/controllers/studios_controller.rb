class StudiosController < ApplicationController

  before_filter :form_info
  before_filter :authenticate_admin!
  skip_before_filter :authenticate_user!, only: [:unsubscribe, :eap]
  after_filter :setup_session_studio_infos, only: [:edit]

  # GET /studios
  # GET /studios.json
  def index
    @logoize = params[:logoize]
    @studios = Studio.by_logoize(@logoize).includes(:owner, :sessions, :minisite, :info)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @studios }
    end
  end

  # GET /studios/1
  # GET /studios/1.json
  def show
    @studio = Studio.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @studio }
    end
  end

  # GET /studios/new
  # GET /studios/new.json
  def new
    if current_user.admin?
      @studio          = Studio.new(info:     MyStudio::Info.new,
                                    minisite: MyStudio::Minisite.new)
      attrs            = {first_pass: User.generate_random_text}
      attrs[:password] = attrs[:first_pass]
      @studio.build_owner(attrs)
    else
      @studio = Studio.new(info:     MyStudio::Info.new(email: current_user.email),
                           minisite: MyStudio::Minisite.new,
                           owner:    current_user)
    end
    @my_studio = @studio
    respond_to do |format|
      format.html
      format.json { render json: @studio }
    end
  end

  def new_owner
    @studio = Studio.find(params[:id])
    @studio.build_owner
  end

  # GET /studios/1/edit
  def edit
    @studio = Studio.find(params[:id])
  end

  # POST /studios
  # POST /studios.json
  def create
    owner_info = params[:studio].delete(:owner_attributes)
    @studio    = Studio.new(params[:studio])
    notice     = 'Studio was successfully created.'
    if is_admin?
      notice = 'Studio was successfully created with no owner.'
      if owner_info[:email].present?
        # create the user, make them owner, don't send email (yet)
        owner = User.new(owner_info.merge(password: owner_info[:first_pass]))
        owner.skip_confirmation!
        @studio.owner = owner
        notice        = 'Studio created with owner but no email sent.'
      end
    else
      @studio.owner = User.find(owner_info[:id])
    end
    respond_to do |format|
      if @studio.save
        format.html { redirect_to current_user.admin? ? studios_path : my_studio_minisite_path(@studio), notice: notice }
        format.json { render json: @studio, status: :created, location: @studio }
      else
        format.html { render action: "new" }
        format.json { render json: @studio.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_owner
    owner_info              = params[:studio].delete(:owner_attributes)
    @studio                 = Studio.find(params[:id])
    owner_info[:first_pass] = User.generate_random_text
    owner                   = User.new(owner_info.merge(password: owner_info[:first_pass]))
    owner.skip_confirmation!
    respond_to do |format|
      if owner.save && @studio.owner = owner
        # TODO review these paths!
        format.html { redirect_to studios_path, notice: 'Studio owner created, but email not sent.' }
      else
        @studio.errors[:base] << owner.errors.full_messages
        @studio.build_owner(owner_info)
        format.html { render action: "new_owner" }
      end
    end
  end

  # PUT /studios/1
  # PUT /studios/1.json
  # Assumes only the studio owner will be updating here.
  def update
    @studio = Studio.find(params[:id])
    @studio.update_attributes(params[:studio])
    respond_to do |format|
      if @studio.save
        format.html do
          if request.xhr?
            render text: @studio.sales_status
          elsif params[:updating_sales]
            redirect_to studios_path, notice: "#{@studio.name} sales notes updated."
          else
            redirect_to edit_studio_path(@studio), notice: "Studio was successfully updated."
          end
        end
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @studio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /studios/1
          # DELETE /studios/1.json
  def destroy
    @studio = Studio.find(params[:id])
    @studio.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = 'Successfully deleted a studio!'
        redirect_to studios_url
      end
      format.json { head :ok }
    end
  end

  def show_branding
    @my_studio          = Studio.find(params[:id])
    @my_studio_minisite = @my_studio.minisite
    render 'my_studio/minisites/show'
  end

  def unsubscribe
    email = params[:email]
    if User.exists?(email: email)
      Unsubscribe.create(email: email) unless Unsubscribe.exists?(email: email)
      render 'minisite/emails/unsubscribe', layout: false
    else
      render(text: 'No email found with that email address.')
    end
  end

  def send_studio_email
    studio = Studio.find(params[:id])
    email = params[:email]
    Notifier.delay.send(email, studio.id)
    StudioEmail.create(email_name: email, studio: studio, sent_at: Time.now)
    respond_to do |format|
      format.js do
        render text: "$('#send_email_#{studio.id}_#{email}').html('queueing email...').effect('highlight', 2000)"
      end
    end
  end

  def send_studio_email_campaign
    email = params[:email]
    count = 0
    Studio.with_logo.each do |studio|
      unless StudioEmail.exists?(email_name: email, studio_id: studio)
        count += 1
        Notifier.delay.send(email, studio.id)
        StudioEmail.create(email_name: email, studio: studio, sent_at: Time.now)
      end
    end
    respond_to do |format|
      format.js do
        render text: "$('#send_email_campaign_#{email}').html('queueing #{count} emails...').effect('highlight', 2000)"
      end
    end
  end

  def emails
    @navbar_active = :studios_emails
    @studios = Studio.where("my_studio_minisites.image IS NOT NULL").joins(:minisite).includes(:studio_emails).all
    @unsubscribes = Unsubscribe.all
  end

  def sales_notes
    @studio = Studio.find(params[:id])
  end

  private #==========================================================================

  def form_info
    @states = State.form_selector
  end

  def navbar_active
    @navbar_active = is_admin? ? :studios : :minisite
  end

  def setup_session_studio_infos
    session[:my_studio_infos] ||= {}
    session[:my_studio_infos][:studio_id] = @studio.id
  end

end