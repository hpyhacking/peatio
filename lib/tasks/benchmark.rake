namespace :benchmark do

  desc "In memory matching engine benchmark"
  task :matching => %w(environment) do
    max_round = round(2)
    puts "\n>> Setup environment (num=#{num} round=#{max_round})"
    Dir[Rails.root.join('tmp', 'matching_result_*')].each {|f| FileUtils.rm(f) }

    Benchmark::Matching.new(label, num, max_round).run
  end

  desc "Trade execution benchmark"
  task :execution => %w(environment) do
    max_round = round(2)
    puts "\n>> Setup environment (executor=#{executor} num=#{num} round=#{max_round})"
    Dir[Rails.root.join('tmp', 'matching_result_*')].each {|f| FileUtils.rm(f) }

    Benchmark::Execution.new(label, num, max_round, executor).run
  end

  desc "Run integration benchmark"
  task :integration => %w(environment) do
    puts "Integration Benchmark (num: #{num(400)})\n"

    Benchmark::Integration.new(num).run
  end

  desc "Profiling"
  task :profiling,  [:type]=> %w(environment) do |task, args|

    case args[:type]

    when 'matching'
      puts "\n>> Setup environment (num=#{num} round=#{round})"
      Dir[Rails.root.join('tmp', 'profiling_matching_result_*')].each {|f| FileUtils.rm(f) }
      file_path = Rails.root.join('tmp', "profiling_matching_result_#{Time.now.to_i}")

      File.open(file_path, 'w') { |file| file.puts "\n>> Setup environment (num=#{num} round=#{round})" }

      Benchmark::Profiling.matching(label, num, round, file_path)

    when 'execution'
      puts "\n>> Setup environment (executor=#{executor} num=#{num} round=#{round})"
      Dir[Rails.root.join('tmp', 'profiling_execution_result_*')].each {|f| FileUtils.rm(f) }

      file_path = Rails.root.join('tmp', "profiling_execution_result_#{Time.now.to_i}")
      File.open(file_path, 'w') { |file| file.puts "\n>> Setup environment (executor=#{executor} num=#{num} round=#{round})" }

      Benchmark::Profiling.execution(label, num, round, executor, file_path)

    else
      puts "\n>> Wrong parameter!"
    end
  end

  def num
    ENV['NUM'] ? ENV['NUM'].to_i : 100
  end

  def round r = 1
    ENV['ROUND'] ? ENV['ROUND'].to_i : r
  end

  def label
    ENV['LABEL'] || Time.now.to_i
  end

  def executor
    ENV['EXECUTOR'] ? ENV['EXECUTOR'].to_i : 6
  end
end

