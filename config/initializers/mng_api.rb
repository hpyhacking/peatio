# frozen_string_literal: true

require 'yaml'
require 'erb'
require 'openssl'

raw_file = File.read('config/management_api.yml')
yaml = ERB.new(raw_file).result

(::YAML.safe_load(yaml) || {}).deep_symbolize_keys!.tap do |x|
  x.fetch(:keychain).each do |id, key|
    begin
      key = OpenSSL::PKey.read(Base64.urlsafe_decode64(key.fetch(:value)))
    rescue OpenSSL::PKey::PKeyError
      raise "Invalid public key format for key #{id} (value: #{key.fetch(:value)})"
    end
    if key.private?
      raise ArgumentError, "keychain. #{id} was set to private key, " \
                           'however it should be public (in config/management_api_v1.yml).'
    end
    x[:keychain][id][:value] = key
  end

  x.fetch(:scopes).values.each do |scope|
    %i[permitted_signers mandatory_signers].each do |list|
      scope[list] = scope.fetch(list, []).map(&:to_sym)
      if list == :mandatory_signers && scope[list].empty?
        raise ArgumentError, "scopes.#{scope}.#{list} is empty, " \
                             'however it should contain at least one value (in config/management_api_v1.yml).'
      end
    end
  end

  Rails.configuration.x.security_configuration = x
end
