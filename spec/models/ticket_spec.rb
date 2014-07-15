# == Schema Information
#
# Table name: tickets
#
#  id         :integer          not null, primary key
#  content    :text
#  state      :string(255)
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
end
