require 'spec_helper'

describe MailerHelper do

  describe '#working_time' do

    it { expect(helper.working_time?("10:00".to_time)).to be true }
    it { expect(helper.working_time?("20:00".to_time)).to be false }

  end

end
