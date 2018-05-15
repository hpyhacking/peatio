# encoding: UTF-8
# frozen_string_literal: true

class Hash
  def fetch!(key)
    raise RuntimeError, "Required key #{key.inspect} is missing or is blank!" unless self[key].present?
    self[key]
  end
end
