describe Ticket do
  describe 'Validation' do
    context 'Both title and content is empty' do
      subject { Ticket.new }
      it { should_not be_valid }
    end

    context 'Title is empty' do
      subject { Ticket.new(content: 'xman is here') }
      it { should be_valid }
    end

    context 'Content is empty' do
      subject { Ticket.new(title: 'xman is here') }
      it { should be_valid }
    end
  end

  describe '#title_for_display' do
    let(:text) { 'alsadkjf aslkdjf aslkdjfla skdjf alsdkjf dlsakjf lasdkjf sadkfasdf xx' }
    context 'title is present' do
      let(:ticket) { create(:ticket, title: text) }
      subject { ticket.title_for_display }

      it { is_expected.to eq 'alsadkjf aslkdjf aslkdjfla skdjf alsdkjf dlsakjf lasdkjf ...' }
    end
  end

  describe '#send_notification' do
    let(:ticket) { create(:ticket) }
    let(:mail) { TicketMailer.admin_notification(ticket.id) }

    it 'should notify the admin' do
      expect(mail.from).to include('system@peatio.tech')
      expect(mail.subject).to eq '[PEATIO] User created a new ticket'
    end
  end
end
