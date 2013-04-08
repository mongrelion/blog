require 'spec_helper'

describe Kernel do
  describe '#root' do
    it "must return application's root path" do
      Kernel.root.must_match /\/carlosleon.info$/
    end
  end
end
