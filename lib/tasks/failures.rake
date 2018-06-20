# encoding: UTF-8
# frozen_string_literal: true

namespace :failures do
  desc 'Fetch Trade Execution Errors'
  task trade_errors: :environment do

    conn = Bunny.new AMQPConfig.connect
    conn.start

    ch = conn.create_channel

    q = ch.queue("peatio.trades.errors")
    puts "******  Fetching Queue Messages  ******"
    count = q.message_count
    puts "******  Total Messages in queue = #{count}  ******"
    errors = []
    until count == 0
      delivery_info, metadata, payload = q.pop
      payload = JSON.parse(payload).symbolize_keys!
      err_obj = payload.fetch(:error)
      if err = errors.find{|k| k[:code] == err_obj.fetch("code")}
        err[:count] += 1
      else
        errors << {code: err_obj.fetch("code"), count: 1 }
      end
      count -= 1
    end

    errors.each do |error|
      puts "******  Error Code: #{error[:code]}  Count = #{error[:count]}  ******"
    end
    puts "******  purging queue  *******"
    q.purge

  end
end
