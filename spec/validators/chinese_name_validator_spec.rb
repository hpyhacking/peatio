require 'spec_helper'

describe ChineseNameValidator do
  before :all do
    class Validatable
      include ActiveModel::Validations

      attr_accessor :name

      validates :name, chinese_name: true
    end
  end

  after(:all) { Object.send(:remove_const, :Validatable) }

  subject { Validatable.new }

  context "Just Chinese characters" do
    before { subject.name = "太太" }
    it { should be_valid }
  end

  context "Contain numbers" do
    before { subject.name = "太123"}
    it { should_not be_valid }
  end

  context "Contain English letters" do
    before { subject.name = "太shuai"}
    it { should_not be_valid }
  end

  context "Contain both English letters and numbers" do
    before { subject.name = "太shuai1e"}
    it { should_not be_valid }
  end

end
