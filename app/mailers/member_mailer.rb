class MemberMailer < BaseMailer

  def notify_signin(member_id)
    member = Member.find member_id
    mail to: member.email
  end

  def google_auth_activated(member_id)
    member = Member.find member_id
    mail to: member.email
  end

  def google_auth_deactivated(member_id)
    member = Member.find member_id
    mail to: member.email
  end
end
