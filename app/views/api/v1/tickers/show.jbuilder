json.ticker do 
  json.buy @ticker[:buy]
  json.sell @ticker[:sell]
  json.low @ticker[:low]
  json.high @ticker[:high]
  json.last @ticker[:last]
  json.vol @ticker[:volume]
end

json.at @ticker[:at]
