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
end
