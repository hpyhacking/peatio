namespace :yarn do
  task :install do
    system 'yarn install --modules-folder ./vendor/assets/yarn_components/yarn_components'
  end
end
