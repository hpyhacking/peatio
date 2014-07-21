module Private::TicketsHelper
  def member_tittle(author)
    if current_user == author
      I18n.t('private.tickets.me')
    else
      I18n.t('private.tickets.supporter')
    end
  end

  def close_open_toggle_link
    if params[:closed]
      link_to t('private.tickets.view_open_tickets'), tickets_path
    else
      link_to t('private.tickets.view_closed_tickets'), tickets_path(closed: true)
    end
  end

end
