# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  content    :text
#  author_id  :integer
#  ticket_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Comment do
  describe "#send_notification" do
    let!(:author) { create(:member, email: 'terry@apple.com') }
    let!(:admin)  { create(:member) }
    let!(:ticket) { create(:ticket, author: author) }

    context "admin reply the ticket" do
      let!(:comment) { create(:comment, author: admin, ticket: ticket)}
      let(:mailer) { mock() }
      before { mailer.stubs(:deliver) }

      it "should notify the author" do
        CommentMailer.expects(:notify).with('terry@apple.com', comment).returns(mailer)
        comment.send(:send_notification)
      end
    end

    context "author reply the ticket" do
      let!(:comment) { create(:comment, author: author, ticket: ticket)}

      it "should not notify the author" do
        CommentMailer.expects(:notify).never
        comment.send(:send_notification)
      end

    end
  end
end
