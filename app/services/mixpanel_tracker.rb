class MixpanelTracker

  def initialize(token)
    @tracker = Mixpanel::Tracker.new token
  end

  def signin(mp_cookie, member)
    @tracker.alias member.email, mp_cookie['distinct_id']
    @tracker.people.set(member.email, get_profile(member))
  end

  private

  def get_profile(member)
    { '$email'       => member.email,
      '$name'        => member.name,
      '$created'     => member.created_at,
      'sn'           => member.sn,
      'phone_number' => member.phone_number }
  end

end
