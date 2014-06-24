class MixpanelTracker

  class <<self
    def instance
      @instance ||= new(ENV['MIXPANEL_TOKEN'])
    end

    def track(action, *args)
      return unless ENV['MIXPANEL_TOKEN'].present?
      instance.send action, *args
    end
  end

  def initialize(token)
    @tracker = Mixpanel::Tracker.new(token) do |type, message|
      AMQPQueue.enqueue(:mixpanel, [type, message])
    end
  end

  def activate(mp_cookie, member)
    return unless mp_cookie
    @tracker.track mp_cookie['distinct_id'], "Activation", email: member.try(:email)
    @tracker.alias member.email, mp_cookie['distinct_id'] if member
    @tracker.people.set(member.email, get_profile(member))
  end

  def id_document_created(mp_cookie, id_document)
    member = id_document.member
    @tracker.people.set(member.email, '$name' => member.name, 'verified' => true)
  end

  def order_accepted(order)
    id = order.member.email
    @tracker.track id, "Order Accepted", order.to_matching_attributes
    @tracker.people.increment id, "Order Accepted" => 1
  end

  def order_canceled(order)
    id = order.member.email
    @tracker.track id, "Order Canceled", order.to_matching_attributes
    @tracker.people.increment id, "Order Canceled" => 1
  end

  def sms_token_sent(mp_cookie, member, token)
    @tracker.track member.email, "SMS Verify Code Sent", phone: token.phone_number, code: token.token
  end

  def phone_number_verified(mp_cookie, member, token)
    @tracker.track member.email, "Phone Number Verified", phone: token.phone_number, code: token.token
    @tracker.people.set member.email, '$phone' => token.phone_number
  end

  private

  def get_profile(member)
    { '$email'       => member.email,
      '$name'        => member.name,
      '$created'     => member.created_at,
      'sn'           => member.sn,
      '$phone'       => member.phone_number }
  end

end
