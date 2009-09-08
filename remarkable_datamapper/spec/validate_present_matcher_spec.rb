require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'validate_presence_of' do
  include ModelBuilder

  # Defines a model, create a validation and returns a raw matcher
  def define_and_validate(options={})
    @model = define_model :product, :id => DataMapper::Types::Serial, :title => String, :size => String, :category => String do
      validates_present :title, :size, options
    end

    validate_present(:title, :size)
  end

  describe 'messages' do
    before(:each){ @matcher = define_and_validate }

    it 'should contain a description' do
      @matcher.description.should == 'require title and size to be set'
    end

    it 'should set nullable? message' do
      @matcher = validate_present(:category)
      @matcher.matches?(@model)
      @matcher.failure_message.should == 'Expected Product to require category to be set'
      @matcher.negative_failure_message.should == 'Did not expect Product to require category to be set'
    end
  end

  describe 'matchers' do
    describe 'without options' do
      before(:each){ define_and_validate }

      it { should validate_present(:size)         }
      it { should validate_present(:title)        }
      it { should validate_present(:title, :size) }
      it { should_not validate_present(:category) }
    end

    create_message_specs(self)

    describe 'with belongs to' do
      def define_and_validate(validation)
        define_model :category, :id => DataMapper::Types::Serial

        define_model :product, :id => DataMapper::Types::Serial, :category_id => Integer do
          belongs_to :category
          validates_present :category if validation
        end

        validate_present(:category)
      end

      it { should define_and_validate(true) }
      it { should_not define_and_validate(false) }
    end

    describe 'with has many' do
      def define_and_validate(validation)
        define_model :stock, :id => DataMapper::Types::Serial, :product_id => Integer

        define_model :product, :id => DataMapper::Types::Serial do
          has n, :stocks
          #validates_present :stocks if validation  # TODO: Translate to DM
        end

        validate_present :stocks
      end

      it { should define_and_validate(true) }
      it { should_not define_and_validate(false) }
    end
  end

  describe 'macros' do
    before(:each){ define_and_validate }

    should_validate_present(:size)
    should_validate_present(:title)
    should_validate_present(:size, :title)
    should_not_validate_present(:category)
  end
end

