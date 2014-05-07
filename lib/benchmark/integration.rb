module Benchmark
  class Integration
    include Helpers

    def initialize(num)
      @num = num
    end

    def run
      Benchmark.benchmark(Benchmark::CAPTION, 20, Benchmark::FORMAT) do |x|
        x.report("create members") { create_members }
        x.report("lock funds")     { lock_funds }
        x.report("create orders")  { create_orders }
      end

      Signal.trap("INT") do
        AMQPQueue.channel.work_pool.kill
        puts "\nFinished."
      end

      t1 = Time.now
      count = 0
      AMQPQueue.channel.queue('', auto_delete: true).bind(AMQPQueue.exchange(:trade)).subscribe do |info, what, payload|
        t = Time.now - t1
        count += 1
        orate = "%.2f" % (@num.to_f/t)
        trate = "%.2f" % (count.to_f/t)
        print "\rTime elapsed: #{t}s   Orders: total #{@num}, rate #{orate}o/s   Trades: total #{count}, rate #{trate}t/s          "
      end

      @orders.each do |o|
        AMQPQueue.enqueue(:matching, action: 'submit', order: o.to_matching_attributes)
      end

      AMQPQueue.channel.work_pool.join
    end

  end
end
