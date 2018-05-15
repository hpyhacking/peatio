# encoding: UTF-8
# frozen_string_literal: true

Rake::Task['currencies:seed'].invoke
Rake::Task['markets:seed'].invoke
