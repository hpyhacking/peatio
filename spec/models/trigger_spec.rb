# encoding: UTF-8
# frozen_string_literal: true

describe Trigger do
  let(:trigger){ create(:trigger) }

  it do
    expect{trigger}.to_not raise_error
  end
end
