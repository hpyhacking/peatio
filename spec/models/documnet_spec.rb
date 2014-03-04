require 'spec_helper'

describe Document do
  describe "locale specific title setters & getters" do
    it 'sets the title in respective locales' do
      I18n.locale = :en
      d = Document.new
      d.en_title = 'Good morning!'
      d.zh_cn_title = '早上好'

      d.save

      expect(Document.with_translations('en').last.en_title).to eq('Good morning!')
      expect(Document.with_translations('zh-CN').last.zh_cn_title).to eq('早上好')
      expect(I18n.locale).to eq(:en)
    end
  end

  describe "locale specific body setters" do
    it 'sets the body in respective locales' do
      d = Document.new
      d.en_body = 'Good morning!'
      d.zh_cn_body = '早上好'

      d.save

      expect(Document.with_translations('en').last.en_body).to eq('Good morning!')
      expect(Document.with_translations('zh-CN').last.zh_cn_body).to eq('早上好')
    end
  end
end
