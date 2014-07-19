# == Schema Information
#
# Table name: tickets
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text
#  aasm_state :string(255)
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Ticket do
  describe "Validation" do
    context "Both title and content is empty" do
      subject { Ticket.new }
      it { should_not be_valid }
    end

    context "Title is empty" do
      subject { Ticket.new(content: 'xman is here') }
      it { should be_valid }
    end

    context "Content is empty" do
      subject { Ticket.new(title: 'xman is here') }
      it { should be_valid }
    end

  end

  describe "#title_for_display" do
    let(:text) { 'alsadkjf aslkdjf aslkdjfla skdjf alsdkjf dlsakjf lasdkjf sadkfasdf xx' }
    context "title is present" do
      let(:ticket) { create(:ticket, title: text)}
      subject{ ticket }
      its(:title_for_display) { should == "alsadkjf aslkdjf aslkdjfla skdjf alsdkjf dlsakjf lasdkjf ..." }
    end

    context "title is blank" do
      let(:ticket) { create(:ticket, content: text) }
      subject{ ticket }
      its(:title_for_display) { should == "alsadkjf aslkdjf aslkdjfla skdjf alsdkjf dlsakjf lasdkjf ..." }
    end
  end

  describe "#send_notification" do
    let(:ticket) { create(:ticket) }
    let(:mailer) { mock() }
    before do
      mailer.stubs(:deliver)
      ticket
    end

    after do
      ticket.send(:send_notification)
    end

    it "should notify the admin" do
      TicketMailer.expects(:admin_notification).with(ENV['SUPPORTERS_EMAILS'], ticket).returns(mailer)
    end
  end
end
