class BigDecimal

  def div_with_precision(d)
    prec = precs.first + d.precs.first
    div(d, prec)
  end

  def mult_and_round(d)
    prec = [precs.first, d.precs.first].min
    mult(d, prec)
  end

end
