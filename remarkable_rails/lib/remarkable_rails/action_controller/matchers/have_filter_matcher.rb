module Remarkable
  module ActionController
    module Matchers
      # Do not inherit from ActionController::Base since it don't need all macro stubs behavior.
      class HaveFilterMatcher < Remarkable::Base #:nodoc:
        arguments :type, :name

        optionals :except, :only, :splat => true
        assertions :has_filter?, :only_matches?, :except_matches?

        before_assert do
          @options[:only]   = [*@options[:only]].compact
          @options[:except] = [*@options[:except]].compact
        end

        protected

          def has_filter?
            @filter = filter
            !@filter.nil?
          end

          def only_matches?
            match(:only)
          end

          def except_matches?
            match(:except)
          end

        private

          def filter
            subject_class.filter_chain.select { |f| f.method == @name.to_sym && f.type == @type }.first
          end

          def match(key)
            return true if @options[key].empty?

            actual = @filter.options[key].to_a
            actual.sort!
            actual.map!{ |a| a.to_sym }

            @options[key].map!{ |a| a.to_s }
            @options[key].sort!
            @options[key].map!{ |a| a.to_sym }

            return actual == @options[key], :actual => actual.inspect
          end

          def interpolation_options
            options = {}
            options[:macro] = Remarkable.t(@type, :scope => matcher_i18n_scope, :default => @type.to_s)
            options[:human_name]  = Remarkable.t(@name, :scope => matcher_i18n_scope, :default => @name.to_s.gsub("_", " "))
            options
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
      def have_before_filter(*args, &block)
        HaveFilterMatcher.new(:before, *args, &block).spec(self)
      end

    end
  end
end
