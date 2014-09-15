class MemberMailer < BaseMailer

  def notify_signin(member_id)
    member = Member.find member_id
    mail to: member.email
  end

end
