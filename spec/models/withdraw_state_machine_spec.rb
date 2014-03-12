require 'spec_helper'

describe Withdraw do
  subject { create(:withdraw, sum: 1000) }

  before do
    subject.stubs(:send_withdraw_confirm_email)
    Resque.stubs(:enqueue)
  end

  it 'initializes with state :submitting' do
    expect(subject.submitting?).to be_true
  end

  it 'transitions to :submitted after calling #submit!' do
    subject.submit!

    expect(subject.submitted?).to be_true
    expect(subject.sum).to eq subject.account.locked
    expect(subject.sum).to eq subject.account_versions.last.locked
  end

  it 'transitions to :accepted with normal account after calling #submit!' do
    subject.submit!

    Job::Examine.perform(subject.id)

    expect(subject.reload.accepted?).to be_true
  end

  it 'transitions to :suspect with suspect account after calling #submit!' do
    subject.account.update_attribute(:balance, 1000.to_d)
    subject.submit!

    Job::Examine.perform(subject.id)

    expect(subject.reload.suspect?).to be_true
  end

  it 'transitions to :rejected after calling #reject!' do
    subject.submit!
    subject.accept!
    subject.reject!

    expect(subject.rejected?).to be_true
  end

  context :process do
    before do
      subject.submit!
      subject.accept!
      subject.process!
    end

    it 'transitions to :processing after calling #process!' do
      expect(subject.processing?).to be_true
    end

    it 'transitions to :done after calling #succeed!' do
      subject.expects(:send_coins).returns(true)

      expect { subject.succeed! }.to change{subject.account.amount}.by(-subject.sum)

      expect(subject.done?).to be_true
    end

    it 'transitions to :almost_done after calling #succeed! when send_coins raise Exception' do
      Resque.expects(:enqueue).raises(StandardError)
      expect { subject.succeed! }.to change{subject.account.amount}.by(-subject.sum)

      expect(subject.almost_done?).to be_true
    end

    it 'transitions to :failed after calling #fail!' do
      expect { subject.fail! }.to_not change{subject.account.amount}

      expect(subject.failed?).to be_true
    end
  end

  context :cancel do
    it 'transitions to :canceled after calling #cancel!' do
      subject.cancel!

      expect(subject.canceled?).to be_true
      expect(subject.account.locked).to eq 0
    end

    it 'transitions from :submitted to :canceled after calling #cancel!' do
      subject.submit!
      subject.cancel!

      expect(subject.canceled?).to be_true
      expect(subject.account.locked).to eq 0
    end

    it 'transitions from :accepted to :canceled after calling #cancel!' do
      subject.submit!
      subject.accept!
      subject.cancel!

      expect(subject.canceled?).to be_true
      expect(subject.account.locked).to eq 0
    end
  end
end
