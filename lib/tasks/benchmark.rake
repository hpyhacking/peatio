namespace :benchmark do

  desc "In memory matching engine benchmark"
  task :matching => %w(environment) do
    num   = ENV['NUM'] ? ENV['NUM'].to_i : 250
    round = ENV['ROUND'] ? ENV['ROUND'].to_i : 4
    label = ENV['LABEL'] || Time.now.to_i

    puts "\n>> Setup environment (num=#{num} round=#{round})"
    Dir[Rails.root.join('tmp', 'matching_result_*')].each {|f| FileUtils.rm(f) }

    Benchmark::Matching.new(label, num, round).run
  end

  desc "Trade execution benchmark"
  task :execution => %w(environment) do
    executor = ENV['EXECUTOR'] ? ENV['EXECUTOR'].to_i : 8
    num   = ENV['NUM'] ? ENV['NUM'].to_i : 250
    round = ENV['ROUND'] ? ENV['ROUND'].to_i : 4
    label = ENV['LABEL'] || Time.now.to_i

    puts "\n>> Setup environment (executor=#{executor} num=#{num} round=#{round})"
    Dir[Rails.root.join('tmp', 'matching_result_*')].each {|f| FileUtils.rm(f) }
    Dir[Rails.root.join('tmp', 'concurrent_executor_*')].each {|f| FileUtils.rm(f) }

    Benchmark::Execution.new(label, num, round, executor).run
  end

  desc "Run integration benchmark"
  task :integration => %w(environment) do
    num = ENV['NUM'] ? ENV['NUM'].to_i : 400
    puts "Integration Benchmark (num: #{num})\n"

    Benchmark::Integration.new(num).run
  end

end
