# encoding: UTF-8
# frozen_string_literal: true

Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::MULTI_STATEMENTS
