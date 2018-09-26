# encoding: UTF-8
# frozen_string_literal: true
require 'open3'

namespace :yarn do
  task :install do
    stdout, stderr, status = Open3.capture3("yarn install --modules-folder ./vendor/assets/yarn_components/yarn_components")
    puts stdout
  end
end
