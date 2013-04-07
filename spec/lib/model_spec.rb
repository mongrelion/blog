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
        it 'should raise an error if no table_name is set' do
          klass = Class.new { include Model }
          proc { klass.all }.must_raise Exception, 'table_name not set.'
        end
      end
    end

    describe '#table_name' do
      it 'should not be exposed to instances' do
        Class.new { include Model }.new.respond_to?(:table_name).must_equal false
      end
    end

    describe "#set_table_name" do
      it "should be included in the public method's list" do
        klass = Class.new { include Model }
        klass.respond_to?(:set_table_name).must_equal true
      end

      it "should not be exposed to instances" do
        klass = Class.new { include Model }
        klass.new.respond_to?(:set_table_name).must_equal false
      end

      it "should only take symbols as argument" do
        proc {
          Class.new do
            include Model
            set_table_name 'foo'
          end
        }.must_raise ArgumentError, /Symbol expected/
      end

      it "should set table_name" do
        klass = Class.new do
          include Model
          set_table_name :foo
        end

        klass.table_name.must_equal :foo
      end

      it "should let set table_name nicely between different classes" do
        foo_class = Class.new do
          include Model
          set_table_name :foo
        end

        # bar_class, if you know what I mean.
        bar_class = Class.new do
          include Model
          set_table_name :bar
        end

        foo_class.table_name.must_equal :foo
        bar_class.table_name.must_equal :bar
      end
    end
  end
end
