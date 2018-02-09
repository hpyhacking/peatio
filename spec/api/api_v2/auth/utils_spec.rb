describe APIv2::Auth::Utils do
  describe '#generate_access_key' do
    it 'should be a string longer than 40 characters' do
      expect(subject.generate_access_key).to match(/^[a-zA-Z0-9]{40}$/)
    end
  end

  describe '#generate_secret_key' do
    it 'should be a string longer than 40 characters' do
      expect(subject.generate_secret_key).to match(/^[a-zA-Z0-9]{40}$/)
    end
  end
end
