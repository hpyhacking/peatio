class AdminFeeder < MemberFeeder
  def feed(email, *args)
    super(email, *args)
  end
end
