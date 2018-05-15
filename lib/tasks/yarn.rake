# encoding: UTF-8
# frozen_string_literal: true

namespace :yarn do
  task :install do
    system 'yarn install --modules-folder ./vendor/assets/yarn_components/yarn_components'
  end
end
