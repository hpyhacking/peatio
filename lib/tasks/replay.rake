namespace :replay do

  desc "replay account balances"
  task account: :environment do
    puts "begin replaying at #{Time.now}"
    players = Member.find_all_by_email(['foo@peatio.dev','bar@peatio.dev']).collect do |m|
      {id: m.id, balance_array: replay(m, [])}
    end
    students = Member.find_all_by_email(['foo@peatio.dev','bar@peatio.dev']).collect do |m|
      {id: m.id, balance_array: replay(m, [])}
    end

    puts '*' * 80
    puts "replaying again at #{Time.now}"

    players = players.collect do |player|
      m = Member.find(player[:id])
      {id: m.id, balance_array: replay(m, player[:balance_array])}
    end

    students = players.collect do |player|
      m = Member.find(player[:id])
      {id: m.id, balance_array: replay(m, player[:balance_array])}
    end

    puts "Finished replaying at #{Time.now}"

    IO.write(Rails.root.to_s + '/all.json', (players  + students).to_json)
  end

  private
  def replay(m, bln_arr)
    puts "replaying for #{m.email}"

    period = 600
    start = Date.new(2014, 8, 1).to_time
    start = Time.at(start.to_i + bln_arr.size * period)
    arr_size = bln_arr.size + (Time.now.to_i - start.to_i) / period + 1

    balances = {'btc' => [], 'cny' => []}
    m.accounts.each do |acc|
      next unless balances.keys.include?(acc.currency)
      v0 = acc.versions.order(:id).where('created_at < ?', start).last
      balances[acc.currency] = arr = [v0.amount]

      acc.versions.select([:created_at, :amount]).order(:id).where('abs(locked) != abs(balance) and created_at >= ?', start).each do |v|
        index = (v.created_at.to_i - start.to_i - period) / period
        arr[bln_arr.size + index + 1] = v.amount if arr[bln_arr.size + index + 1].nil?
      end
      arr[arr_size - 1] = acc.versions.last.amount
      arr = arr[0, arr_size] if arr.count > arr_size

      arr.each_with_index{|item, index| arr[index] = arr[index - 1] if arr[index].nil?}
      arr.collect!{|item| item.to_f.round(2) }
    end

    (bln_arr.size...arr_size).each do |i|
      price = Trade.with_currency('btccny').where('created_at <= ?', Time.at(start.to_i + period * i)).last.price
      bln_arr[i] = (balances['cny'][i] + (balances['btc'][i] - 1) * price).to_f.round(2).to_s
    end

    bln_arr
  end

  def replay_student(m)
    puts "replaying for #{m.email}"

    period = 600
    start = Date.new(2014, 8, 1).to_time
    start = Time.at(start.to_i + bln_arr.size * period)
    arr_size = bln_arr.size + (Time.now.to_i - start.to_i) / period + 1

    balances = {'btc' => [], 'cny' => []}
    m.accounts.each do |acc|
      next unless balances.keys.include?(acc.currency)
      v0 = acc.versions.order(:id).where('created_at < ?', start).last
      balances[acc.currency] = arr = [v0.amount]

      acc.versions.select([:created_at, :amount]).order(:id).where('abs(locked) != abs(balance) and created_at >= ?', start).each do |v|
        index = (v.created_at.to_i - start.to_i - period) / period
        arr[bln_arr.size + index + 1] = v.amount if arr[bln_arr.size + index + 1].nil?
      end
      arr[arr_size - 1] = acc.versions.last.amount
      arr = arr[0, arr_size] if arr.count > arr_size

      arr.each_with_index{|item, index| arr[index] = arr[index - 1] if arr[index].nil?}
      arr.collect!{|item| item.to_f.round(2) }
    end

    (bln_arr.size...arr_size).each do |i|
      price = Trade.with_currency('btccny').where('created_at <= ?', Time.at(start.to_i + period * i)).last.price
      bln_arr[i] = ((balances['cny'][i] + (balances['btc'][i] - 0.1) * price) * 10).to_f.round(2).to_s
    end

    bln_arr
  end
end
