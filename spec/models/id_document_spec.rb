# == Schema Information
#
# Table name: id_documents
#
#  id           :integer          not null, primary key
#  category     :integer
#  name         :string(255)
#  sn           :string(255)
#  member_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#  verified     :boolean
#  birth_date   :date
#  address      :text
#  city         :string(255)
#  country      :string(255)
#  zipcode      :string(255)
#  id_bill_type :integer
#  aasm_state   :string(255)
#

require 'spec_helper'

describe IdDocument do
  let(:member) { create(:member) }
  subject { member.id_document }

  it { should be_valid }

  context 'aasm_state' do
    describe 'default state' do
      its(:aasm_state) { should eq('unapproved') }
    end

    describe 'submit' do
      before do
        subject.submit
      end

      its(:aasm_state) { should eq('pending_approve') }
    end

    describe 'approved' do
      before do
        subject.submit
        subject.approve
      end

      its(:aasm_state) { should eq('approved') }
    end

    describe 'reject' do
      before do
        subject.submit
        subject.reject
      end

      its(:aasm_state) { should eq('unapproved') }
    end
  end
end
