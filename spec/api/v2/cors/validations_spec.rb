# encoding: UTF-8
# frozen_string_literal: true

describe CORS::Validations do
  describe 'validate origins' do
    subject { CORS::Validations.validate_origins(ENV['API_CORS_ORIGINS']) }

    context 'set API_CORS_ORIGINS as "*"' do
      before { ENV['API_CORS_ORIGINS'] = '*' }

      it { is_expected.to eq('*') }

      after { ENV['API_CORS_ORIGINS'] = nil }
    end

    context 'set mulitple API_CORS_ORIGINS with "*"' do
      before { ENV['API_CORS_ORIGINS'] = 'https://localhost,*,https://domain.com' }

      it { is_expected.to eq('*') }

      after { ENV['API_CORS_ORIGINS'] = nil }
    end

    context 'set multiple API_CORS_ORIGINS' do
      before { ENV['API_CORS_ORIGINS'] = 'https://localhost,https://domain.com' }

      it { is_expected.to eq(['https://localhost','https://domain.com']) }

      after { ENV['API_CORS_ORIGINS'] = nil }
    end

    context 'set invalid domain into API_CORS_ORIGINS' do
      before { ENV['API_CORS_ORIGINS'] = 'htt:://localhost' }

      it { expect { subject }.to raise_error(CORS::Validations::Error) }

      after { ENV['API_CORS_MAX_AGE'] = nil }
    end
  end

  describe 'validate max age' do
    subject { CORS::Validations.validate_max_age(ENV['API_CORS_MAX_AGE']) }

    context 'set API_CORS_MAX_AGE as "6200"' do
      before { ENV['API_CORS_MAX_AGE'] = '6200' }

      it { is_expected.to eq('6200') }

      after { ENV['API_CORS_MAX_AGE'] = nil }
    end

    context 'set API_CORS_MAX_AGE as "6200.1"' do
      before { ENV['API_CORS_MAX_AGE'] = '6200.1' }

      it { is_expected.to eq('3600') }

      after { ENV['API_CORS_MAX_AGE'] = nil }
    end

    context 'doesn\'t set API_CORS_MAX_AGE"' do
      before { ENV['API_CORS_MAX_AGE'] = nil }

      it { is_expected.to eq('3600') }
    end
  end
end
