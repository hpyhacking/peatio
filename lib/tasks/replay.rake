namespace :replay do

  desc "replay account balances"
  task account: :environment do
    puts "loading all.json"
    path = Rails.root.to_s + '/all.json'
    data = File.exist?(path) ? JSON.load(File.open(path)) : []

    puts "begin replaying at #{Time.now}"
    players = Member.find_all_by_email(['foo@peatio.dev','bar@peatio.dev']).collect do |m|
      previous = data.find{|hash| hash['id'] == m.id }
      array = previous ? previous['balance_array'] : []
      {id: m.id, balance_array: replay(m, array)}
    end

    students = Member.find_all_by_email(['foo@peatio.dev','bar@peatio.dev']).collect do |m|
      previous = data.find{|hash| hash['id'] == m.id }
      array = previous ? previous['balance_array'] : []
      {id: m.id, balance_array: replay_student(m, array)}
    end

    puts "Finished replaying at #{Time.now}"

    IO.write(Rails.root.to_s + '/all.json', (players  + students).to_json)
  end

  private
  def replay(m, bln_arr)
    puts "replaying for #{m.email}"

    period = 600
    start = Time.new(2014, 8, 1, 12, 0, 0)
    start = Time.at(start.to_i + bln_arr.size * period)
    arr_size = bln_arr.size + (Time.now.to_i - start.to_i) / period + 1

    puts "#{bln_arr.size} -> "

    balances = {'btc' => [], 'cny' => []}
    m.accounts.each do |acc|
      next unless balances.keys.include?(acc.currency)
      v0 = acc.versions.order(:id).where('created_at < ?', start).last
      balances[acc.currency] = arr = [v0.amount]

      acc.versions.select([:id, :created_at, :amount]).order(:id).where('abs(locked) != abs(balance) and id > ?', v0.id).find_in_batches(batch_size: 20000) do |versions|
        versions.each do |v|
          index = (v.created_at.to_i - start.to_i - period) / period
          arr[bln_arr.size + index + 1] = v.amount
        end
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

    puts "#{bln_arr.size}"

    bln_arr
  end

  def replay_student(m, bln_arr)
    puts "replaying for #{m.email}"

    period = 600
    start = Time.new(2014, 8, 1, 12, 0, 0)
    start = Time.at(start.to_i + bln_arr.size * period)
    arr_size = bln_arr.size + (Time.now.to_i - start.to_i) / period + 1

    puts "#{bln_arr.size} -> "

    balances = {'btc' => [], 'cny' => []}
    m.accounts.each do |acc|
      next unless balances.keys.include?(acc.currency)
      v0 = acc.versions.order(:id).where('created_at < ?', start).last
      balances[acc.currency] = arr = [v0.amount]

      acc.versions.select([:id, :created_at, :amount]).order(:id).where('abs(locked) != abs(balance) and id > ?', v0.id).find_in_batches(batch_size: 20000) do |versions|
        versions.each do |v|
          index = (v.created_at.to_i - start.to_i - period) / period
          arr[bln_arr.size + index + 1] = v.amount
        end
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

    puts "#{bln_arr.size}"

    bln_arr
  end
end
