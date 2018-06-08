# encoding: UTF-8
# frozen_string_literal: true

namespace :barong do
  desc 'Refresh access level for Barong members.'
  task levels: :environment do
    url = "https://#{ENV.fetch('BARONG_DOMAIN')}/api/account"
    t   = Authentication.arel_table
    Authentication
      .where(provider: :barong)
      .where(t[:token].is_not_blank)
      .where(t[:member_id].is_not_blank)
      .includes(:member)
      .order(updated_at: :asc)
      .limit(1000)
      .each do |auth|
        next if auth.token.blank? || auth.member.blank?

        profile       = JSON.parse(Faraday.get(url, nil, 'Authorization' => "Bearer #{auth.token}").assert_success!.body)
        current_level = auth.member.level
        new_level     = profile.fetch('level')

        unless current_level == new_level
          auth.member.update!(level: new_level)
          auth.touch
          Rails.logger.info { "#{auth.member.email}: #{current_level} >> #{new_level}." }
        end
      rescue => e
        report_exception(e)
      end
  end
end
