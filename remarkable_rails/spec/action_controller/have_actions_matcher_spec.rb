require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'have_actions' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @controller = define_controller :Posts do
        def index
        end
      end.new

      @matcher = have_action(:index)
    end

    it 'should contain a description message' do
      @matcher.description.should == 'respond to index'
    end

    it 'should set has_action? message' do
      @controller = define_controller(:Comments).new
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected controller to respond to index'
    end
  end

  describe 'having action' do
    before(:each) do 
      @controller = define_controller :Comments do
        def index
        end
        
        def create
        end
      end.new

      self.class.subject { @controller }
    end

    should_have_actions [:index, :create]
    should_have_action :index
  end

  describe 'not having action' do
    before(:each) do 
      @controller = define_controller(:Comments).new
      self.class.subject { @controller }
    end

    should_not_have_actions [:destroy, :update]
    should_not_have_action :destroy
  end

end
