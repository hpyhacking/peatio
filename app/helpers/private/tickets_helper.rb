module Private::TicketsHelper
  def member_tittle(author)
    if current_user == author
      I18n.t('private.tickets.me')
    else
      I18n.t('private.tickets.supporter')
    end
  end
end
