# encoding: UTF-8
# frozen_string_literal: true

#= PasswordGenerator
#
#== Usage
#
# >> PasswordGenerator.generate
# => "2pN@cxj+zs!SVogtPZ&u"
#
# >> PasswordGenerator.generate(40)
# => "B5xPy2unMKjRchfS($7v)q4N%oF*lGz@+OJ6LbVD"
module PasswordGenerator
  CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a + %w{! @ # $ % & / ( ) + ? *}

  class << self
    def generate(length = 20)
      CHARS.sort_by { rand }.join[0...length]
    end
  end
end
