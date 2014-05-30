require 'spec_helper'

describe OrderAsk do

  subject { create(:order_ask) }

  its(:compute_locked) { should == subject.volume }

end
