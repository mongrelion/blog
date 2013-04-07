require 'minitest/autorun'
require 'minitest/spec'
require 'model'
require 'kernel'

describe Model do
  describe "class including Model" do
    describe '#new' do
      it 'must return a new instance of OpenStruct class' do
        Car = Class.new(Model)
        Car.new.must_be_kind_of OpenStruct
      end

      it 'should assign attributes' do
        Computer = Class.new(Model)
        computer = Computer.new keyboard: true, trackpad: true, os: 'OS X'
        computer.keyboard.must_equal true
        computer.trackpad.must_equal true
        computer.os.must_equal 'OS X'
      end
    end
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

        it 'should return an array of records' do
          Model.stub :base_dir, File.join(root, 'spec/support') do
            Apple = Class.new(Model) { set_db_file :apples }
            apples = Apple.all
            apples.must_be_kind_of Array
            apples.must_equal [
              Apple.new({:color=>"red", :weight=>"50gr", :country=>"Chile"}),
              Apple.new({:color=>"green", :weight=>"63gr", :country=>"Colombia"})
            ]
          end
        end

        it 'should raise an exception if no db_file is set' do
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
