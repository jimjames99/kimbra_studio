class ClientMailer < ActionMailer::Base

  helper :application

  default from: "Support <support@KimbraClickPLUS.com>"

  def send_offers(email_id)
    @email = Admin::Customer::Email.find(email_id)
    @client = @email.my_studio_session.client
    @studio = @email.my_studio_session.studio
    logo = ''
    open('image.jpg', 'w') do |file|
      logo << open(@studio.minisite.image_url).read
    end
    attachments.inline['logo.png'] = logo
    mail(to: "#{@client.name} <#{@client.email}>",
         bcc: ['support@kimbraclickplus.com', 'jim@jimjames.org'],
         subject: 'Your recent photos in heirloom jewelry.',
         from: "#{@studio.name} <support@KimbraClickPLUS.com>")
  end

  def send_order_confirmation(cart_id, studio_id)
    @cart = Shopping::Cart.find(cart_id)
    @studio = Studio.find(studio_id)
    @show_status_only = true
    mail(to: "#{@cart.address.first_name} #{@cart.address.last_name} <#{@cart.address.email}>",
         subject: "Photo Jewelry receipt from #{@studio.name} (Order number: #{@cart.tracking})",
         bcc: ['support@kimbraclickplus.com', 'jim@jimjames.org'],
         from: "#{@studio.name} <support@KimbraClickPLUS.com>")
  end

  def send_shipping_update(cart_id, studio_id)
    @cart = Shopping::Cart.find(cart_id)
    @studio = Studio.find(studio_id)
    @show_status_only = true
    mail(to: "#{@cart.address.first_name} #{@cart.address.last_name} <#{@cart.address.email}>",
         subject: "Your Photo Jewelry order has shipped. #{@studio.name}",
         bcc: ['support@kimbraclickplus.com', 'jim@jimjames.org'],
         from: "#{@studio.name} <support@KimbraClickPLUS.com>")
  end

end