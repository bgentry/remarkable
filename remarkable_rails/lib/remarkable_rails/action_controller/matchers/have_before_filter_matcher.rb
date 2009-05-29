module Remarkable
  module ActionController
    module Matchers
      # Do not inherit from ActionController::Base since it don't need all macro stubs behavior.
      class HaveBeforeFilterMatcher < Remarkable::Base #:nodoc:
        arguments :name
        
        optionals :except, :only

        assertions :has_before_filter?

        protected

          def has_before_filter?
            filter =  @subject.class.filter_chain.select { |filter| filter.method.eql? @name }.first
            return false if filter.nil?
            options = filter.options
            return false unless match(:except, options)
            return false unless match(:only, options)
            return true
          end
          
        private
          def match(key, options)
            spec_options = option(key) 
            unless spec_options.nil?
              filter_options = options[key]
              return false if filter_options.nil?
              return filter_options.sort == spec_options.map { |item| item.to_s }.sort
            end
            true
          end
        
          def option(key)
            option = @options[key]
            option.nil? ? nil : [option].flatten
          end
      end

      # Checks if the controller has a filter.
      #
      # == Examples
      #
      #   should_have_before_filter :login_required
      #   should_have_before_filter :login_required, :except => :edit
      #   should_have_before_filter :login_required, :only => [:edit, :create]
      #
      #   it { should have_before_filter :login_required }
      #   it { should have_before_filter :login_required, :except => :edit }
      #   it { should have_before_filter :login_required, :only => [:edit, :create] }      
      #
      def have_before_filter(*params)
        HaveBeforeFilterMatcher.new(*params).spec(self)
      end
      
    end
  end
end
