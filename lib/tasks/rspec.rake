require 'rspec/core/rake_task'

Rake::Task['spec:performance'].actions.clear

namespace :spec do
  RSpec::Core::RakeTask.new(:performance) do |t|
    t.pattern    = 'spec/performance/**/*_spec.rb'
    t.rspec_opts = '-t performance -f d'
  end
end
