require 'spec_helper'

describe Identity do
  it { should allow_value("pas1Word").for(:password) }
  it { should allow_value("pas1Wo@d").for(:password) }
  it { should allow_value("pas1Wo_d").for(:password) }
  it { should allow_value("123456").for(:password) }
  it { should_not allow_value("pwd").for(:password) }

  it "should unify email" do
    create(:identity, email: 'foo@example.com')
    build(:identity, email: 'Foo@example.com').should_not be_valid
  end

end
