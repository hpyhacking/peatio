require 'benchmark/amqp_mock'
require 'ruby-prof'

module Benchmark
  class Profiling
    class Matching
      include Helpers

      def initialize(label, num, round, file_path)
        @label = label.to_s
        @num = num
        @round = round
        @times = Hash.new {|h,k| h[k] = [] }
        @file_path = file_path
      end

      def run
        run_prepare_orders
        run_matching_orders
        run_execute_trades
      end

      def run_prepare_orders
        (1..@round).map do |i|
          puts "\n>> Round #{i}"
          print_results_to_file(RubyProf.profile { create_members }, i, "Create Members")
          print_results_to_file(RubyProf.profile { lock_funds }, i, "Lock Funds")
          print_results_to_file(RubyProf.profile { create_orders }, i, "Create Orders")
          nil
        end
      end

      def run_matching_orders
        puts "\n>> Match Them All"
        file = File.open(@file_path, "a")
        file.puts "************ Matching Orders Results ********"
        file.puts RubyProf::FlatPrinter.new(RubyProf.profile { matching_orders }).print(file)
        str = "#{@matches} matches run for #{@processed} orders, #{@instructions.size} trade instruction generated."
        file.puts str
        file.close
        puts str
      end

      def run_execute_trades
        puts "\n>> Execute Trade Instructions"
        file = File.open(@file_path, "a")
        file.puts "************ Execute Trades Results ********"
        file.puts RubyProf::FlatPrinter.new(RubyProf.profile { execute_trades }).print(file)
        str = "#{@instructions.size} trade instructions executed, #{@trades} trade created."
        file.puts str
        file.close
        puts str
      end

      private

      def print_results_to_file result, round, method
        file = File.open(@file_path, "a")
        file.puts "************ Round = #{round},  #{method} Results ********"
        file.puts RubyProf::FlatPrinter.new(result).print(file)
        file.close
      end
    end
  end
end