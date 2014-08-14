namespace :replay do

  desc "replay account balances"
  task account: :environment do
    start = Date.new(2014, 8, 1).to_time
    period = 600
    arr_size = (Time.now.to_i - start.to_i) / period + 1

    players = Member.find_all_by_email(['foo@peatio.dev','bar@peatio.dev']).collect do |m|
      puts "replaying for #{m.email}"
      balances = {'btc' => [], 'cny' => []}
      m.accounts.each do |acc|
        next unless balances.keys.include?(acc.currency)
        v0 = acc.versions.order(:id).where('created_at < ?', start).last
        balances[acc.currency] = arr = [v0.amount]

        acc.versions.order(:id).where('abs(locked) != abs(balance) and created_at >= ?', start).each do |v|
          index = (v.created_at.to_i - start.to_i - period) / period
          arr[index + 1] = v.amount if arr[index + 1].nil?
        end
        arr[arr_size - 1] = acc.versions.last.amount
        arr = arr[0, arr_size] if arr.count > arr_size

        arr.each_with_index{|item, index| arr[index] = arr[index - 1] if arr[index].nil?}
        arr.collect!{|item| item.to_f.round(2) }
      end

      bln_arr = []
      (0...balances['cny'].count).each do |i|
        price = Trade.with_currency('btccny').where('created_at <= ?', Time.at(start.to_i + period * i)).last.price
        bln_arr[i] = (balances['cny'][i] + (balances['btc'][i] - 1) * price).to_f.round(2).to_s
      end
      {id: m.id, balance_array: bln_arr}
    end

    students = Member.find_all_by_email(['foo@peatio.dev']).collect do |m|
      puts "replaying for #{m.email}"
      balances = {'btc' => [], 'cny' => []}
      m.accounts.each do |acc|
        next unless balances.keys.include?(acc.currency)
        v0 = acc.versions.order(:id).where('created_at < ?', start).last
        balances[acc.currency] = arr = [v0.amount]

        acc.versions.order(:id).where('abs(locked) != abs(balance) and created_at >= ?', start).each do |v|
          index = (v.created_at.to_i - start.to_i - period) / period
          arr[index + 1] = v.amount if arr[index + 1].nil?
        end
        arr[arr_size - 1] = acc.versions.last.amount
        arr = arr[0, arr_size] if arr.count > arr_size

        arr.each_with_index{|item, index| arr[index] = arr[index - 1] if arr[index].nil?}
        arr.collect!{|item| item.to_f.round(2) }
      end

      bln_arr = []
      (0...balances['cny'].count).each do |i|
        price = Trade.with_currency('btccny').where('created_at <= ?', Time.at(start.to_i + period * i)).last.price
        bln_arr[i] = ((balances['cny'][i] + (balances['btc'][i] - 0.1) * price) * 10).to_f.round(2).to_s
      end
      {id: m.id, balance_array: bln_arr}
    end

    IO.write(Rails.root.to_s + '/all.json', (players + students).to_json)
  end
end
