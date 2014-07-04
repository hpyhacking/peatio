require 'spec_helper'

describe ChineseIdCardNumValidator do
  before :all do
    class Validatable
      include ActiveModel::Validations

      attr_accessor :sn

      validates :sn, chinese_id_card_num: true
    end
  end

  after :all do
    Object.send(:remove_const, :Validatable)
  end

  subject { Validatable.new }

  context "valid " do
    context "length is 18" do
      before { subject.sn = "510105198504193779" }
      it { should be_valid }
    end

    context "length is 18 with X" do
      before { subject.sn = "51010519850419377X" }
      it { should be_valid }
    end

    context "length is 15" do
      before { subject.sn = "510105198504193" }
      it { should be_valid }
    end
  end


  context "invalid" do
    context "length is 17" do
      before { subject.sn = "51010519850419377" }
      it { should_not be_valid }
    end

    context "length is 15 with X" do
      before { subject.sn = "51010519850419X" }
      it { should_not be_valid }
    end

    context "length is 18 with x(lower case)" do
      before { subject.sn = "51010519850419377x" }
      it { should_not be_valid }
    end

  end
end
