require 'minitest/autorun'
require 'minitest/spec'
require 'model'

describe Model do
  describe "class including module Model" do
    describe "#all" do
      it "should be included in the public method's list" do
        klass = Class.new { include Model }
        klass.respond_to?(:all).must_equal true
      end

      it "should not be exposed to instances" do
        klass = Class.new { include Model }
        klass.new.respond_to?(:all).must_equal false
      end

      describe 'when called' do
        it 'should raise an exception if db file does not exist' do
        end

        it 'should raise an exception if no db_file is set' do
          klass = Class.new { include Model }
          proc { klass.all }.must_raise Exception, 'db_file not set.'
        end
      end
    end

    describe '#db_file' do
      it 'should not be exposed to instances' do
        Class.new { include Model }.new.respond_to?(:db_file).must_equal false
      end
    end

    describe "#set_db_file" do
      it "should be included in the public method's list" do
        klass = Class.new { include Model }
        klass.respond_to?(:set_db_file).must_equal true
      end

      it "should not be exposed to instances" do
        klass = Class.new { include Model }
        klass.new.respond_to?(:set_db_file).must_equal false
      end

      it "should only take symbols as argument" do
        proc {
          Class.new do
            include Model
            set_db_file 'foo'
          end
        }.must_raise ArgumentError, /Symbol expected/
      end

      it "should set db_file" do
        klass = Class.new do
          include Model
          set_db_file :foo
        end

        klass.db_file.must_equal :foo
      end

      it "should let set db_file nicely between different classes" do
        foo_class = Class.new do
          include Model
          set_db_file :foo
        end

        # bar_class, if you know what I mean.
        bar_class = Class.new do
          include Model
          set_db_file :bar
        end

        foo_class.db_file.must_equal :foo
        bar_class.db_file.must_equal :bar
      end
    end
  end
end
