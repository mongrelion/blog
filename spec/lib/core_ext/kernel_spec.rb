require 'minitest/autorun'
require 'minitest/spec'
require 'kernel'

describe Kernel do
  describe '#root' do
    it "must return application's root path" do
      Kernel.root.must_match /\/carlosleon.info$/
    end
  end
end
