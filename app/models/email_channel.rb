class EmailChannel < NotificationChannel
  attr_reader :mailer, :target

  def notify!(payload = {})
    @payload = payload
    setup_mailer_and_target
    @mailer.send(name, target).deliver if notifyable?
  end

  def notifyable?
    member.email_activated
  end

  private

  def setup_mailer_and_target
    if %w[deposit_accepted].include?(name)
      @mailer = DepositMailer
      @target = payload[:deposit_id]
    elsif %w[withdraw_submitted withdraw_processing withdraw_done withdraw_state].include?(name)
      @mailer = WithdrawMailer
      @target = payload[:withdraw_id]
    else
      @mailer = MemberMailer
      @target = member.id
    end
  end
end
