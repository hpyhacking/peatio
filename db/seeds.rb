# encoding: UTF-8
# frozen_string_literal: true

Rake::Task['seed:blockchains'].invoke
Rake::Task['seed:currencies'].invoke
Rake::Task['seed:markets'].invoke
Rake::Task['seed:wallets'].invoke
