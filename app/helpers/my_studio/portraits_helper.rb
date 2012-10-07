module MyStudio::PortraitsHelper

  def feedback_for(portraits)
    return '' if portraits.blank? || portraits.size == 0
    msg = "You have uploaded #{portraits.size == 1 ? 'only 1 portrait' : "#{portraits.size} portraits"} so far. "
    msg << "<br/>We will generate an offer email with as few as 2 portraits but we prefer if you load at least 6 or as many as 20. "
    msg << "<br/>#{6 - portraits.size} to go." unless portraits.size >= 6
    msg.html_safe
  end

  def empty_table_rows
    '<tr><td>No portraits uploaded yet.</td></tr>'.html_safe
  end

  def actions_for_portraits(my_studio_session)
    if my_studio_session.finished_uploading_at?
      'You marked this photo session as complete and it has been scheduled for photoshopping.'
    elsif @my_studio_portraits.size > 2
      button_to('Process my email! I have uploaded a good selection of portraits.', my_studio_session_is_finished_uploading_portraits_path, method: :get)
    end
  end

end