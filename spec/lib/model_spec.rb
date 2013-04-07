require 'minitest/autorun'
require 'minitest/spec'
require 'model'
require 'kernel'

describe Model do
  describe "class including module Model" do
    describe "#all" do
      it "should be included in the public method's list" do
        klass = Class.new Model
        klass.respond_to?(:all).must_equal true
      end

      it "should not be exposed to instances" do
        klass = Class.new Model
        klass.new.respond_to?(:all).must_equal false
      end

      describe 'when called' do
        it 'should raise an exception if db file does not exist' do
          klass = Class.new(Model) { set_db_file :foo }
          proc { klass.all }.must_raise Errno::ENOENT
        end

        it 'should return an array' do
          skip
          Apple = Class.new { include Model; set_db_file :apples }
          Apple.stub :base_dir, File.join(root, 'spec/support') do
            Apple.all.must_be_kind_of Array
          end
        end

        it 'should raise an exception if no db_file is set' do
          klass = Class.new Model
          proc { Class.new(Model).all }.must_raise Exception, 'db_file not set.'
        end
      end
    end

    describe '#db_file' do
      it 'should not be exposed to instances' do
        Class.new(Model).new.respond_to?(:db_file).must_equal false
      end

      it 'should return db_file class instance variable' do
        klass = Class.new(Model) { set_db_file :foo }
        klass.instance_variable_get('@db_file').must_equal klass.db_file
      end
    end

    describe "#set_db_file" do
      it "should be included in the public method's list" do
        Class.new(Model).respond_to?(:set_db_file).must_equal true
      end

      it "should not be exposed to instances" do
        Class.new(Model).new.respond_to?(:set_db_file).must_equal false
      end

      it "should only take symbols as argument" do
        proc {
          Class.new(Model) { set_db_file 'foo' }
        }.must_raise ArgumentError, /Symbol expected/
      end

      it "should set db_file" do
        klass = Class.new(Model) { set_db_file :foo }
        klass.db_file.must_equal :foo
      end

      it "should let set db_file nicely between different classes" do
        Foo = Class.new(Model) { set_db_file :foo }
        Bar = Class.new(Model) { set_db_file :bar }

        Foo.db_file.must_equal :foo
        Bar.db_file.must_equal :bar
      end
    end
  end
end
