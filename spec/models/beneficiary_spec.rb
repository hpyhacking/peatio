# encoding: UTF-8
# frozen_string_literal: true

# TODO: AASM tests.
# TODO: Event API tests.

describe Beneficiary, 'Relationships' do
  context 'beneficiary build by factory' do
    subject { build(:beneficiary) }
    it { expect(subject.valid?).to be_truthy }
  end

  context 'belongs to member' do
    context 'null member_id' do
      subject { build(:beneficiary, member: nil) }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'belongs to currency' do
    context 'null currency_id' do
      subject { build(:beneficiary, currency: nil) }
      it { expect(subject.valid?).to be_falsey }
    end
  end
end

describe Beneficiary, 'Validations' do
  context 'pin presence' do
    context 'nil pin' do
      subject { build(:beneficiary) }
      before { Beneficiary.expects(:generate_pin).returns(nil) }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'pin numericality only_integer' do
    context 'float pin' do
      subject { build(:beneficiary) }
      before { Beneficiary.expects(:generate_pin).returns(3.14) }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'state inclusion' do
    context 'wrong state' do
      subject { build(:beneficiary, state: :wrong) }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'data presence' do
    context 'nil data' do
      subject { build(:beneficiary, data: nil) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'empty hash data' do
      subject { build(:beneficiary, data: {}) }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'data address presence' do
    context 'fiat' do
      context 'blank address' do
        let(:fiat) { Currency.find(:usd)}
        subject { build(:beneficiary, currency: fiat).tap { |b| b.data.delete('address') } }
        it { expect(subject.valid?).to be_truthy }
      end
    end

    context 'coin' do
      context 'blank address' do
        let(:coin) { Currency.find(:btc)}
        subject { build(:beneficiary, currency_id: coin).tap { |b| b.data.delete('address') } }
        it { expect(subject.valid?).to be_falsey }
      end
    end
  end

  context 'data full_name presence' do
    # TODO: Write me.
  end
end

describe Beneficiary, 'Callback' do
  context 'before_validation on create' do
    subject { build(:beneficiary) }
    it 'generates pin' do
      expect(subject.pin).to be_nil
      subject.validate!
      expect(subject.pin).to_not be_nil
      pin = subject.pin
      subject.validate!
      expect(subject.pin).to eq(pin)
    end
  end

  context 'before_create' do
    subject { build(:beneficiary) }
    it 'generates sent_at' do
      expect(subject.sent_at).to be_nil
      subject.save!
      expect(subject.sent_at).to_not be_nil
      expect(subject.sent_at).to eq(subject.created_at)
    end
  end
end

describe Beneficiary, 'Instance Methods' do
  context 'rid' do
    context 'fiat' do
      let(:full_name) { Faker::Name.name_with_middle }
      let(:fiat) { Currency.find(:usd)}

      subject do
        create(:beneficiary,
               currency: fiat,
               data: generate(:fiat_beneficiary_data).merge(full_name: full_name))
      end

      it do
        expect(subject.rid).to include(*full_name.downcase.split)
        expect(subject.rid).to include(subject.id.to_s)
        expect(subject.rid).to include(subject.currency_id)
      end
    end

    context 'coin' do
      let(:address) { Faker::Blockchain::Ethereum.address }
      let(:coin) { Currency.find(:btc) }

      subject do
        create(:beneficiary,
               currency: coin,
               data: generate(:coin_beneficiary_data).merge(address: address))
      end

      it do
        expect(subject.rid).to include(address)
      end
    end
  end

  context 'regenerate pin' do
    subject { create(:beneficiary) }

    it do
      sent_at = subject.sent_at
      pin = subject.pin

      Time.stubs(:now).returns(Time.mktime(1970,1,1))
      subject.regenerate_pin!
      expect(subject.pin).to_not eq(pin)
      expect(subject.sent_at).to_not eq(sent_at)
    end
  end
end
