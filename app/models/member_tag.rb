class MemberTag < Settingslogic
  source "#{Rails.root}/config/member_tag.yml"
  namespace Rails.env
  suppress_errors Rails.env.production?
end
