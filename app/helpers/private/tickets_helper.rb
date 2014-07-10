module Private::TicketsHelper
  def member_tittle(author)
    if current_user == author
      "我" #TODO I18n
    else
      "客服" #TODO I18n
    end
  end
end
