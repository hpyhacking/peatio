# encoding: UTF-8
# frozen_string_literal: true

#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Peatio::Application.load_tasks

# Load additional tasks from "support/tasks".
Dir.glob('lib/peatio/tasks/**/*') { |f| load(f) }
