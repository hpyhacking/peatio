module Vault
  module EncryptedModel
    extend ActiveSupport::Concern

    module ClassMethods
      # Creates an attribute that is read and written using Vault.
      #
      # @example
      #
      #   class Person < ActiveRecord::Base
      #     include Vault::EncryptedModel
      #     vault_attribute :ssn
      #   end
      #
      #   person = Person.new
      #   person.ssn = "123-45-6789"
      #   person.save
      #   person.encrypted_ssn #=> "vault:v0:6hdPkhvyL6..."
      #
      # @param [Symbol] column
      #   the column that is encrypted
      # @param [Hash] options
      #
      # @option options [Symbol] :encrypted_column
      #   the name of the encrypted column (default: +#{column}_encrypted+)
      # @option options [String] :path
      #   the path to the transit backend (default: +transit+)
      # @option options [String] :key
      #   the name of the encryption key (default: +#{app}_#{table}_#{column}+)
      # @option options [String, Symbol, Proc] :context
      #   either a string context, or a symbol or proc used to generate a
      #   context for key generation
      # @option options [Object] :default
      #   a default value for this attribute to be set to if the underlying
      #   value is nil
      # @option options [Symbol, Class] :serializer
      #   the name of the serializer to use (or a class)
      # @option options [Proc] :encode
      #   a proc to encode the value with
      # @option options [Proc] :decode
      #   a proc to decode the value with
      # @option options [Hash] :transform_secret
      #   a hash providing details about the transformation to use,
      #   this includes the name, and the role to use
      def vault_attribute(attribute, options = {})
        # Sanity check options!
        _vault_validate_options!(options)

        parsed_opts = if options[:transform_secret]
                        parse_transform_secret_attributes(attribute, options)
                      else
                        parse_transit_attributes(attribute, options)
                      end
        parsed_opts[:encrypted_column] = options[:encrypted_column] || "#{attribute}_encrypted"

        # Make a note of this attribute so we can use it in the future (maybe).
        __vault_attributes[attribute.to_sym] = parsed_opts

        self.attribute attribute.to_s, ActiveRecord::Type::Value.new,
          default: nil

        # Getter
        define_method("#{attribute}") do
          self.__vault_load_attributes!(attribute) unless @__vault_loaded
          super()
        end

        # Setter
        define_method("#{attribute}=") do |value|
          self.__vault_load_attributes!(attribute) if !@__vault_loaded && @vault_setter_decrypt

          # We always set it as changed without comparing with the current value
          # because we allow our held values to be mutated, so we need to assume
          # that if you call attr=, you want it sent back regardless.

          attribute_will_change!("#{attribute}")
          instance_variable_set("@#{attribute}", value)
          super(value)

          # Return the value to be consistent with other AR methods.
          value
        end

        # Checker
        define_method("#{attribute}?") do
          self.__vault_load_attributes!(attribute) unless @__vault_loaded
          instance_variable_get("@#{attribute}").present?
        end

        self
      end

      # The list of Vault attributes.
      #
      # @return [Hash]
      def __vault_attributes
        @vault_attributes ||= {}
      end

      # Validate that Vault options are all a-okay! This method will raise
      # exceptions if something does not make sense.
      def _vault_validate_options!(options)
        if options[:serializer]
          if options[:encode] || options[:decode]
            raise Vault::Rails::ValidationFailedError, "Cannot use a " \
              "custom encoder/decoder if a `:serializer' is specified!"
          end

          if options[:transform_secret]
            raise Vault::Rails::ValidationFailedError, "Cannot use the " \
              "transform secrets engine with a specified `:serializer'!"
          end
        end

        if options[:encode] && !options[:decode]
          raise Vault::Rails::ValidationFailedError, "Cannot specify " \
            "`:encode' without specifying `:decode' as well!"
        end

        if options[:decode] && !options[:encode]
          raise Vault::Rails::ValidationFailedError, "Cannot specify " \
            "`:decode' without specifying `:encode' as well!"
        end

        if context = options[:context]
          if context.is_a?(Proc) && context.arity != 1
            raise Vault::Rails::ValidationFailedError, "Proc passed to " \
              "`:context' must take 1 argument!"
          end
        end
        if transform_opts = options[:transform_secret]
          if !transform_opts[:transformation]
            raise Vault::Rails::VaildationFailedError, "Transform Secrets " \
              "requires a transformation name!"
          end
        end
      end

      def vault_lazy_decrypt
        @vault_lazy_decrypt ||= false
      end

      def vault_lazy_decrypt!
        @vault_lazy_decrypt = true
      end

      def vault_single_decrypt
        @vault_single_decrypt ||= false
      end

      def vault_single_decrypt!
        @vault_single_decrypt = true
      end

      def vault_enable_setter_decrypt!
        @vault_setter_decrypt = true
      end

      private

      def parse_transform_secret_attributes(attribute, options)
        opts = {}
        opts[:transform_secret] = true

        serializer = Class.new
        serializer.define_singleton_method(:encode) do |raw|
          return if raw.nil?
          resp = Vault::Rails.transform_encode(raw, options[:transform_secret])
          resp.dig(:data, :encoded_value)
        end
        serializer.define_singleton_method(:decode) do |raw|
          return if raw.nil?
          resp = Vault::Rails.transform_decode(raw, options[:transform_secret])
          resp.dig(:data, :decoded_value)
        end
        opts[:serializer] = serializer
        opts
      end

      def parse_transit_attributes(attribute, options)
        opts = {}
        opts[:path] = options[:path] || "transit"
        opts[:key] = options[:key] || "#{Vault::Rails.application}_#{table_name}_#{attribute}"
        opts[:context] = options[:context]
        opts[:default] = options[:default]

        # Get the serializer if one was given.
        serializer = options[:serialize]

        # Unless a class or module was given, construct our serializer. (Slass
        # is a subset of Module).
        if serializer && !serializer.is_a?(Module)
          serializer = Vault::Rails.serializer_for(serializer)
        end

        # See if custom encoding or decoding options were given.
        if options[:encode] && options[:decode]
          serializer = Class.new
          serializer.define_singleton_method(:encode, &options[:encode])
          serializer.define_singleton_method(:decode, &options[:decode])
        end

        opts[:serializer] = serializer
        opts
      end
    end

    included do
      # After a resource has been initialized, immediately communicate with
      # Vault and decrypt any attributes unless vault_lazy_decrypt is set.
      after_initialize :__vault_initialize_attributes!

      # After we save the record, persist all the values to Vault and reload
      # them attributes from Vault to ensure we have the proper attributes set.
      # The reason we use `after_save` here is because a `before_save` could
      # run too early in the callback process. If a user is changing Vault
      # attributes in a callback, it is possible that our callback will run
      # before theirs, resulting in attributes that are not persisted.
      after_save :__vault_persist_attributes!

      # Decrypt all the attributes from Vault.
      # @return [true]
      def __vault_initialize_attributes!
        if self.class.vault_lazy_decrypt
          @__vault_loaded = false
          return
        end

        __vault_load_attributes!
      end

      def __vault_load_attributes!(attribute_to_read = nil)
        self.class.__vault_attributes.each do |attribute, options|
          # skip loading certain keys in one of two cases:
          # 1- the attribute has already been loaded
          # 2- the single decrypt option is set AND this is not the attribute we're requesting to decrypt
          next if instance_variable_get("@#{attribute}") || (self.class.vault_single_decrypt && attribute_to_read != attribute)
          self.__vault_load_attribute!(attribute, options)
        end

        @__vault_loaded = self.class.__vault_attributes.all? { |attribute, __| instance_variable_get("@#{attribute}") }

        return true
      end

      # Decrypt and load a single attribute from Vault.
      def __vault_load_attribute!(attribute, options)
        key        = options[:key]
        path       = options[:path]
        serializer = options[:serializer]
        column     = options[:encrypted_column]
        context    = options[:context]
        default    = options[:default]
        transform  = options[:transform_secret]

        # Load the ciphertext
        ciphertext = read_attribute(column)

        # If the user provided a value for the attribute, do not try to load
        # it from Vault
        if attributes[attribute.to_s]
          return
        end

        # Generate context if needed
        generated_context = __vault_generate_context(context)

        if transform
          # If this is a secret encrypted with FPE, we do not need to decrypt with vault
          # This prevents a double encryption via standard vault encryption and FPE.
          # FPE is decrypted later as part of the serializer
          plaintext = ciphertext
        else
          # Load the plaintext value
          plaintext = Vault::Rails.decrypt(
            path, key, ciphertext,
            context: generated_context
          )
        end

        # Deserialize the plaintext value, if a serializer exists
        if serializer
          plaintext = serializer.decode(plaintext)
        end

        # Set to default if needed
        if default && plaintext == nil
          plaintext = default
        end

        # Write the virtual attribute with the plaintext value
        instance_variable_set("@#{attribute}", plaintext)
        @attributes.write_from_database attribute.to_s, plaintext
      end

      # Encrypt all the attributes using Vault and set the encrypted values back
      # on this model.
      # @return [true]
      def __vault_persist_attributes!
        changes = {}

        self.class.__vault_attributes.each do |attribute, options|
          if c = self.__vault_persist_attribute!(attribute, options)
            changes.merge!(c)
          end
        end

        # If there are any changes to the model, update them all at once,
        # skipping any callbacks and validation. This is okay, because we are
        # already in a transaction due to the callback.
        if !changes.empty?
          self.update_columns(changes)
        end

        return true
      end

      # Encrypt a single attribute using Vault and persist back onto the
      # encrypted attribute value.
      def __vault_persist_attribute!(attribute, options)
        key        = options[:key]
        path       = options[:path]
        serializer = options[:serializer]
        column     = options[:encrypted_column]
        context    = options[:context]
        transform  = options[:transform_secret]

        # Only persist changed attributes to minimize requests - this helps
        # minimize the number of requests to Vault.
        if ActiveRecord.gem_version >= Gem::Version.new("6.0")
          return unless previous_changes.include?(attribute)
        elsif ActiveRecord.gem_version >= Gem::Version.new("5.2")
          return unless previous_changes_include?(attribute)
        elsif ActiveRecord.gem_version >= Gem::Version.new("5.1")
          return unless saved_change_to_attribute?(attribute.to_s)
        else
          return unless attribute_changed?(attribute)
        end

        # Get the current value of the plaintext attribute
        plaintext = attributes[attribute.to_s]

        # Apply the serialize to the plaintext value, if one exists
        if serializer
          plaintext = serializer.encode(plaintext)
        end

        # Generate context if needed
        generated_context = __vault_generate_context(context)

        if transform
          # If this is a secret encrypted with FPE, we should not encrypt it in vault
          # This prevents a double encryption via standard vault encryption and FPE.
          # FPE was performed earlier as part of the serialization process.
          ciphertext = plaintext
        else
          # Generate the ciphertext and store it back as an attribute
          ciphertext = Vault::Rails.encrypt(
            path, key, plaintext,
            context: generated_context
          )
        end

        # Write the attribute back, so that we don't have to reload the record
        # to get the ciphertext
        write_attribute(column, ciphertext)

        # Return the updated column so we can save
        { column => ciphertext }
      end

      # Generates an Vault Transit encryption context for use on derived keys.
      def __vault_generate_context(context)
        case context
        when String
          context
        when Symbol
          send(context)
        when Proc
          context.call(self)
        else
          nil
        end
      end

      # Override the reload method to reload the Vault attributes. This will
      # ensure that we always have the most recent data from Vault when we
      # reload a record from the database.
      def reload(*)
        super.tap do
          # Unset all the instance variables to force the new data to be pulled
          # from Vault
          self.class.__vault_attributes.each do |attribute, _|
            self.instance_variable_set("@#{attribute}", nil)
            @attributes.write_from_database attribute.to_s, nil
          end

          self.__vault_initialize_attributes!
        end
      end
    end
  end
end