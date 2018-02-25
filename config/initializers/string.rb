class String
  def to_d
    blank? ? 0.0.to_d : BigDecimal.new(self)
  end
end
