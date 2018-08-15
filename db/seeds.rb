# encoding: UTF-8
# frozen_string_literal: true

# NOTE: The order of task matters because Currency belongs_to Blockchain.
Rake::Task['seed:blockchains'].invoke
Rake::Task['seed:currencies'].invoke
Rake::Task['seed:markets'].invoke
Rake::Task['seed:wallets'].invoke
