require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'have_filter' do
  include FunctionalBuilder

  describe 'messages' do
    before(:each) do
      @controller = define_controller :Posts do
        before_filter :require_user, :only => [:edit, :update]
      end.new

      @matcher = have_before_filter(:require_user)
    end

    it 'should contain a description message' do
      @matcher.only(:new, :create)
      @matcher.description.should == 'require user before :new and :create actions'
    end

    it 'should set has_filter? message' do
      @matcher = have_before_filter(:foo)
      @matcher.matches?(@controller)
      @matcher.failure_message.should == 'Expected controller to have before filter :foo'
    end

    it 'should set only_matches? message' do
      @matcher.only(:new).matches?(@controller)
      @matcher.failure_message.should == 'Expected controller to have before filter :require_user on [:new], got [:edit, :update]'
    end

    it 'should set except_matches? message' do
      @matcher.except(:new).matches?(@controller)
      @matcher.failure_message.should == 'Expected controller to except before filter :require_user on [:new], got []'
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

    # Should not allow a subset match
    should_not_have_before_filter :validate_payment, :only => :new
    should_not_have_before_filter :jump, :except => :edit

    should_not_have_before_filter :validate_ip
    should_not_have_before_filter :validate_payment, :except => :destroy
    should_not_have_before_filter :jump, :only => :show
  end
end
