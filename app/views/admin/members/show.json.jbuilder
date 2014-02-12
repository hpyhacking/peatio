json.base do
  json.id @member.id
  json.sn @member.sn
  json.email @member.email
end

json.accounts @accounts do |a|
  json.currency a.currency
  json.balance a.balance
  json.locked a.locked
  json.sum a.locked + a.balance
end
