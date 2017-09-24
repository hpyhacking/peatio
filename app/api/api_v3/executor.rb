class MyHandler < EM::Connection

  include FE::ServerConnection

  def on_market_data_request
    # Fetch market data and send the relevant response
    #  ...
  end

end
def gogogo
  puts "starting at: #{Time.now}"
  server = FE::Server.new('127.0.0.1', 8095, MyHandler) do |conn|
    conn.comp_id = 'MY_COMP_ID'
  end
  # This will also start an EventMachine reactor
  server.run!
  # This would be used inside an already-running reactor
  EM.run do
    server.start_server()
  end
end
t1 = Thread.new{gogogo()}
#t1.join
puts "Ending at: #{Time.now}"

