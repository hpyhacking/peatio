require 'benchmark/profiling/execution'
require 'benchmark/profiling/matching'

module Benchmark
  class Profiling

    class << self

      def matching(label, num, round, file_path)
        Matching.new(label, num, round, file_path).run
      end

      def execution(label, num, round, executor, file_path)
        Execution.new(label, num, round, executor, file_path).run
      end
    end
  end
end
