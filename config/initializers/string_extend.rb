class String
  def ellipsisize(len = 10)
    len = 10 unless len > 10 # assumes minimum chars at each end = 3
    gsub(%r{(....).{#{len-5},}(....)}, '\1...\2')
  end

  def mask(before: 5, after: 5)
    gsub(%r{(#{'.' * before}).*(#{'.' * after})}, '\1***\2')
  end

  def mask_address
    gsub(%r{(......).*(......)}, '\1***\2')
  end
end

module Enumerize
  class Attribute
    def value_options(options = {})
      values = if options.empty?
        @values
      else
        raise ArgumentError, 'Options cannot have both :only and :except' if options[:only] && options[:except]

        only = Array(options[:only]).map(&:to_s)
        except = Array(options[:except]).map(&:to_s)

        @values.reject do |value|
          if options[:only]
            !only.include?(value)
          elsif options[:except]
            except.include?(value)
          end
        end
      end
      values.map { |v| [v.text, v.value] }
    end
  end
end
