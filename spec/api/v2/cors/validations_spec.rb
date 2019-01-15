# encoding: UTF-8
# frozen_string_literal: true

describe CORS::Validations do
  describe 'validate origins' do
    subject { CORS::Validations.validate_origins(ENV['API_CORS_ORIGINS']) }

    context 'set API_CORS_ORIGINS as "*"' do
      before do
        ENV['API_CORS_ORIGINS'] = '*'
      end

      it do 
        is_expected.to eq('*')
      end
    end

    context 'set mulitple API_CORS_ORIGINS with "*"' do
      before do
        ENV['API_CORS_ORIGINS'] = 'https://localhost,*,https://domain.com'
      end

      it do 
        is_expected.to eq('*')
      end
    end

    context 'set multiple API_CORS_ORIGINS' do
      before do
        ENV['API_CORS_ORIGINS'] = 'https://localhost,https://domain.com'
      end

      it do 
        is_expected.to eq(['https://localhost','https://domain.com'])
      end
    end

    context 'set invalid domain into API_CORS_ORIGINS' do
      before do
        ENV['API_CORS_ORIGINS'] = 'htt:://localhost'
      end

      it do
        expect { subject }.to raise_error(CORS::Validations::Error)
      end
    end
  end

  describe 'validate max age' do
    subject { CORS::Validations.validate_max_age(ENV['API_CORS_MAX_AGE']) }

    context 'set API_CORS_MAX_AGE as "6200"' do
      before do
        ENV['API_CORS_MAX_AGE'] = '6200'
      end

      it do 
        is_expected.to eq('6200')
      end
    end

    context 'set API_CORS_MAX_AGE as "6200.1"' do
      before do
        ENV['API_CORS_MAX_AGE'] = '6200.1'
      end

      it do 
        is_expected.to eq('3600')
      end
    end

    context 'doesn\'t set API_CORS_MAX_AGE"' do
      before do
        ENV['API_CORS_MAX_AGE'] = nil
      end

      it do 
        is_expected.to eq('3600')
      end
    end
  end
end
