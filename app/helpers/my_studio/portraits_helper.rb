module MyStudio::PortraitsHelper

  def feedback_for(count)
    text = t(:my_studio_portraits_feedback_common,
             min:  MyStudio::Session::MIN_PORTRAITS,
             best: MyStudio::Session::BEST_PORTRAITS,
             max:  MyStudio::Session::MAX_PORTRAITS)
    if count == 0
      msg = text
      msg = "Click the Add Portraits button to begin uploading six or more of your client's portraits."
    else
      msg = "You have uploaded #{count == 1 ? 'only 1 portrait' : "#{count} portraits"} so far. "
      msg << "<br/>#{text}"
      msg << "<br/> <i class='icon-hand-right'> </i> #{MyStudio::Session::BEST_PORTRAITS - count} to go." unless count >= MyStudio::Session::BEST_PORTRAITS
    end
    msg.html_safe
  end

  def empty_table_rows
    '<tr><td>No portraits uploaded yet.</td></tr>'.html_safe
  end

  def what_is_going_on
    "<span><i class='icon-thumbs-up'></i>Some Text#{my_button}</span>".html_safe
  end

  def actions_for_portraits(my_studio_session)
    if my_studio_session.finished_uploading_at?
      'You marked this photo session as complete and it has been scheduled for photoshopping.'
    elsif my_studio_session.complete?
      #button_icon_to(t(:my_studio_sessions_complete_link2, portrait_count: my_studio_session.portraits.count),
      #               'icon-ok-sign icon-white',
      #               my_studio_session_is_finished_uploading_portraits_path,
      #               {method: :get, class: "btn btn-success", title: t(:my_studio_sessions_complete_title)})
      button_icon_to('icon-ok-sign icon-white',
                     t(:my_studio_sessions_complete_link2, portrait_count: my_studio_session.portraits.count),
                     my_studio_session_is_finished_uploading_portraits_path,
                     {method: :get, title: t(:my_studio_sessions_complete_title)})
    end
  end

  def alert_type_for(count)
    case
      when count < MyStudio::Session::MIN_PORTRAITS
        'alert-error'
      when count < MyStudio::Session::BEST_PORTRAITS
        'alert-info'
      when count >= MyStudio::Session::BEST_PORTRAITS && count <= MyStudio::Session::MAX_PORTRAITS
        'alert-success'
      when count > MyStudio::Session::MAX_PORTRAITS
        'alert-error'
      else
        'alert-error'
    end
  end

end