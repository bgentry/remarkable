require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'have_before_filter' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @controller = define_controller :Posts do
        before_filter :require_user, :only => [:edit, :update]
      end.new

      @matcher = have_before_filter(:jump_around, :only => [:new, :save], :except => :destroy)
    end

    it 'should contain a description message' do
      @matcher.description.should == 'jump_around only on new, save and except in destroy'
    end

    it 'should set has_before_filter? message' do
      @controller = define_controller(:Comments).new
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected controller to jump_around on edit, update and except on destroy'
    end
  end

  describe 'validating' do
    before(:each) do 
      @controller = define_controller :Comments do
        before_filter :require_login
        before_filter :validate_payment, :only => [:create, :new]
        before_filter :jump, :except => [:edit, :update]
      end.new

      self.class.subject { @controller }
    end

    should_have_before_filter :require_login
    should_have_before_filter :validate_payment, :only => [:create, :new]
    should_have_before_filter :jump, :except => [:update, :edit]
    
    should_not_have_before_filter :validate_ip
    should_not_have_before_filter :validate_payment, :except => :destroy
    should_not_have_before_filter :jump, :only => :show
    
    should_not_have_before_filter :validate_payment, :only => [:new]
    should_not_have_before_filter :jump, :except => [:edit]
  end
end
