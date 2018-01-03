describe Identity, type: :model do
  it 'accepts right passwords' do
    %w[password p@ssword PaSsworD].each do |pass|
      expect(create(:identity, password: pass, password_confirmation: pass)).to be_valid
    end

    %w[some wrong pass].each do |pass|
      expect { create(:identity, password: pass, password_confirmation: pass) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it 'should unify email' do
    create(:identity, email: 'foo@example.com')
    expect(build(:identity, email: 'Foo@example.com')).not_to be_valid
  end
end
