namespace :identity do
  desc "Add the login_type"
  task reset_login_type: :environment do
    Identity.find_each do |i|
      if i.login =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        i.update_attribute :login_type, 'email'
      elsif i.login =~ /^\d+$/
        i.update_attribute :login_type, 'phone_number'
      end
    end
  end

  desc "Add the mobile identity"
  task add_mobile_identity: :environment do
    Member.find_each do |m|
      if m.phone_number && m.sms_two_factor.activated? && !m.phone_number_activated
        ActiveRecord::Base.transaction do

          i = Identity.new(login: m.phone_number, password_digest: m.identity_email.password_digest,
                           login_type: 'phone_number')
          i.save(validate: false)
          a = m.authentications.new(provider: 'identity', uid: i.id)
          a.save!
          m.update_attribute(:phone_number_activated, true)
        end
      end
    end
  end
end
