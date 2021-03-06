module NavbarHelper

  # create a navbar menu markup for a bootstrap li tag
  # menu => menu symbol in locales.en
  # link_path => route path for menu item
  # en_path => locales.en path to parent menu item (ex. '.menus.misc')
  def li_navbar(menu, link_path, en_path=".menus")
    if (menu.to_s.starts_with?("friend_"))
      name, title = navbar_friends_name_and_title(menu)
    else
      name_method = "navbar_#{menu}_name"
      name = send(name_method) if respond_to?(name_method.to_sym, include_private=true)
      name         ||= t("#{en_path}.#{menu}.name")
      title_method = "navbar_#{menu}_title"
      title = send(title_method) if respond_to?(title_method.to_sym, include_private=true)
      title ||= t("#{en_path}.#{menu}.title")
    end
    element_id   = name.gsub(' ', '')
    link_options = {title: title}
    link_options[:class] = "brand" if menu == :brand
    html_options = {class: menu == @navbar_active ? 'active' : '', id: element_id}
    content_tag(:li, link_to(name, link_path, link_options), html_options).html_safe
  end

  # controllers before_filter#navbar_active
  #   sets the menu symbol that should be set with css_class active
  #
  # li_navbar_or_not(:collection) =>
  #
  #   <li class="active">
  #     <a title="Click to view your custom jewelry collection"
  #         href="/minisite/emails/hydh0yezkf/offers">
  #       My Collection
  #     </a>
  #   </li>
  def li_navbar_or_not(menu)
    # path for the navbar menu item
    path_method = "navbar_#{menu}_path"
    path = send(path_method) if respond_to?(path_method.to_sym, include_private=true)
    path = '#' if path and current_page?(path) # if the current request is this path then stub it out with #
    path ||= "#"
    li_navbar(menu, path)
  end

  # top level navbar menu that contains a sub_menu
  # dropdown_active sets the menu item highlighted when true
  def li_navbar_dropdown_menu(menu, ul_sub_menu_html, dropdown_active)
    html_options = {class: 'dropdown'}
    html_options[:class] += " active" if (menu == @navbar_active) or dropdown_active
    html = content_tag(:li, html_options) do
      "#{navbar_dropdown(menu)}#{ul_sub_menu_html}".html_safe
    end
    html.html_safe
  end

          # construct the navbar dropdown markup for our Misc Menu Item
  def li_navbar_misc
    menu                           = :misc
    # drop down list for the Misc menu
    sub_menus                      = {merchandise:   admin_merchandise_pieces_path,
                                      infos_samples: samples_my_studio_infos_path,
                                      stories:       admin_stories_path,
                                      infos_faqs:    faq_my_studio_infos_path}
    dropdown_active, sub_menu_html = navbar_dropdown_sub_menus(menu, sub_menus)
    li_navbar_dropdown_menu(menu, sub_menu_html, dropdown_active)
  end

  def li_navbar_photo_sessions
    menu = :photo_sessions
    unless is_client?
      if @mock_collection.nil? or (@mock_collection == :return)
        li_navbar_or_not(menu)
      end
    else
      ''
    end
  end

  def li_navbar_friends
    menu      = :friends
    # drop down list for the Friends menu
    sub_menus = {send_offer_email: "#mySendOfferEmail"}
    if (@admin_customer_email)
      current_friend_id = @admin_customer_friend.id if @admin_customer_friend
      @admin_customer_email.friends.each do |friend|
        if (friend.id != current_friend_id)
          if (@admin_customer_email.offers_by_friend(friend.id).size > 0)
            sub_menus["friend_#{friend.id}".to_sym] = index_friends_minisite_email_offers_path(@admin_customer_email, friend.id)
          end
        end
      end
    end
    dropdown_active, sub_menu_html = navbar_dropdown_sub_menus(menu, sub_menus)
    sub_menu_html.gsub!('#mySendOfferEmail"', '#mySendOfferEmail" data-toggle="modal"')
    li_navbar_dropdown_menu(menu, sub_menu_html, dropdown_active)
  end

  def li_navbar_facebook
    if (current_user_facebook)
      li_navbar_or_not(:facebook)
    end
  end

  private #=================================================================

  # top level navbar menu that has dropdown menus
  def navbar_dropdown(menu)
    name  = t(".menus.#{menu}.name")
    title = t(".menus.#{menu}.title")
    "<a href='#' class='dropdown-toggle' data-toggle='dropdown' title='#{title}'> #{name} <b class='caret'></b></a>"
  end

  # generates the sub_menu_html for all sub_menus items
  # returns dropdown_active => true if this sub_menu is currently active
  # the sub_menu_html markup for everything in the sub_menus hash
  # sub_menus => {menu_symbol: link_path_for_sub_menu}
  def navbar_dropdown_sub_menus(menu, sub_menus)
    dropdown_active = false
    en_path         = ".menus.#{menu}"
    html_options    = {class: 'dropdown-menu'}
    # dropdown ul tag containing our sub_menu li tags
    sub_menu_html   = content_tag(:ul, html_options) do
      li_navbars = sub_menus.collect do |sub_menu, link_path|
        dropdown_active = true if (sub_menu == @navbar_active)
        li_navbar(sub_menu, link_path, en_path)
      end
      li_navbars.join(" ").html_safe
    end
    return dropdown_active, sub_menu_html
  end

  # Customize navbar Menu Items
  # path, name, or title
  def navbar_brand_path
    if @admin_customer_email
      #link_to_your_about_or_not(text, @admin_customer_email)
      about_minisite_email_path(@admin_customer_email.tracking)
    else
      '#'
    end
  end

  # customize about menu title text
  def navbar_brand_title
    t('.menus.brand.title', name: @studio.try(:name))
  end

  # minisite menu options for returning
  # the link_path for this menu item
  def navbar_collection_path
    if @admin_customer_email
      index_custom_minisite_email_offers_path(@admin_customer_email.tracking)
    else
      '#'
    end
  end

  def navbar_charms_path
    if @admin_customer_email
      #link_to_your_charms_or_not(text, @admin_customer_email)
      index_charms_minisite_email_offers_path(@admin_customer_email.tracking)
    else
      '#'
    end
  end

  def navbar_chains_path
    if @admin_customer_email
      # link_to_your_chains_or_not(text, @admin_customer_email)
      index_chains_minisite_email_offers_path(@admin_customer_email.tracking)
    else
      '#'
    end
  end

  def navbar_create_custom_path
    if (@admin_customer_email)
      new_minisite_email_offer_path(@admin_customer_email)
    else
      '#'
    end
  end

  def navbar_facebook_path
    if Rails.env.development?
      if @mock_collection
        '#'
      else
        if current_user_facebook
          facebook_signout_path
        else
          '/auth/facebook'
        end
      end
    else
      '#'
    end
  end

  # customize with an image
  def navbar_facebook_name
    if Rails.env.development?
      if current_user_facebook
        t('.menus.facebook.sign_out.name')
      end
    else
      ''
    end
  end

  def navbar_facebook_title
    if Rails.env.development?
      if current_user_facebook
        t('.menus.facebook.sign_out.title')
      end
    else
      ''
    end
  end

  # customize the Name and Title for friends navbar
  #`  based on the link_path info`
  def navbar_friends_name_and_title(menu)
    friend_id = menu.to_s.split('_').last
    if friend = Admin::Customer::Friend.find_by_id(friend_id)
      name  = friend.name.to_s
      title = "Click to View #{name}'s collection"
    end
    return name, title
  end

  def navbar_photo_sessions_path
    #link_to_your_cart_or_not
    if @mock_collection == :return
      samples_my_studio_infos_path
    else
      if is_admin?
        admin_overview_path
      elsif is_studio?
        my_studio_sessions_path
      else
        '#'
      end
    end
  end

  def navbar_photo_sessions_name
    if @mock_collection == :return
      t(".menus.photo_sessions.mock.name")
    else
      t(".menus.photo_sessions.name")
    end
  end

  def navbar_photo_sessions_title
    if @mock_collection == :return
      t(".menus.photo_sessions.mock.title")
    else
      t(".menus.photo_sessions.title")
    end
  end

  def navbar_shopping_cart_path
    #link_to_your_cart_or_not
    @cart ? shopping_cart_path(@cart.tracking) : '#'
  end

  # customize the navbar name for shopping_cart
  def navbar_shopping_cart_name
    name = "#{icon_minisite("icon-shopping-cart")} #{t('.menus.shopping_cart.name')}"
    if @cart
      cart_numericality = content_tag(:span, id: :cart_numericality) do
        pluralize(@cart.try(:quantity), 'piece')
      end
      name              += " #{cart_numericality}"
    end
    name.html_safe
  end

  def navbar_suggestions_path
    if @admin_customer_email
      minisite_email_offers_path(@admin_customer_email.tracking)
    else
      '#'
    end

  end

  def navbar_upload_path
    if (@admin_customer_email)
      minisite_email_portraits_path(@admin_customer_email)
    else
      if (is_client?)
        minisite_email_portraits_path('xyz')
      else
        '#'
      end
    end
  end

end