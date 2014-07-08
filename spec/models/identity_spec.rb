# == Schema Information
#
# Table name: identities
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  is_active       :boolean
#  retry_count     :integer
#  is_locked       :boolean
#  locked_at       :datetime
#  last_verify_at  :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Identity do
  it { should allow_value("pas1Word").for(:password) }
  it { should allow_value("pas1Wo@d").for(:password) }
  it { should allow_value("pas1Wo_d").for(:password) }
  it { should allow_value("123456").for(:password) }
  it { should_not allow_value("pwd").for(:password) }
end
