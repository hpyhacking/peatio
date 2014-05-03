require 'spec_helper'

describe 'I18n KeyPathToHash' do
  subject do
    Class.new { include Peatio::I18n::Backend::Sqlite::KeyPathToHash }.new
  end

  let(:dot_separted_key_path_hash) do
    {
      'activerecord.errors.messages.inclusion' => 'is not included in the list',
      'activerecord.errors.messages.exclusion' => 'は予約されています',
      'tags.vip'  => 'VIP',
      'tags.hero' => 'Hero Member'
    }
  end

  let(:pipe_separted_key_path_hash) do
    {
      'activerecord|errors|messages|inclusion' => 'is not included in the list',
      'activerecord|errors|messages|exclusion' => 'は予約されています',
      'tags|vip'  => 'VIP',
      'tags|hero' => 'Hero Member'
    }
  end

  let(:normal_hash) do
    {
      'activerecord' => {
        'errors' => {
          'messages' => {
            'inclusion' => 'is not included in the list',
            'exclusion' => 'は予約されています'
          }
        }
      },
      'tags' => {
        'vip'  => 'VIP',
        'hero' => 'Hero Member'
      }
    }
  end

  describe "#explode_hash" do
    it "transforms hash with KeyPath form keys to normal one" do
      subject.explode_hash(dot_separted_key_path_hash).should == normal_hash
    end

    it "transforms hash with KeyPath form keys separated by specified separator" do
      subject.explode_hash(pipe_separted_key_path_hash, '|').should == normal_hash
    end
  end
end
