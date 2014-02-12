class WhitelistConstraint
  def initialize(list)
    @list = list
  end

  def matches?(request)
    if @list.empty? || @list.include?(request.remote_ip)
      true
    else
      false
    end
  end
end

