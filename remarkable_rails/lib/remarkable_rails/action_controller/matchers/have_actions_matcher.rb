module Remarkable
  module ActionController
    module Matchers
      # Do not inherit from ActionController::Base since it don't need all macro stubs behavior.
      class HaveActionsMatcher < Remarkable::Base #:nodoc:
        arguments :collection => :params, :as => :param

        collection_assertions :has_action?

        protected

          def has_action?
            [@param].flatten.each { |param| return false unless @subject.class.instance_methods.include?(param.to_s) }
            true
          end

      end

      # Checks if the controller respond to the given actions.
      #
      # == Examples
      #
      #   should_have_actions [:new, :create]
      #   should_have_action :show
      #
      #   it { should have_actions([:new, :create]) }
      #   it { should have_action(:show) }
      #
      def have_actions(*params)
        HaveActionsMatcher.new(*params).spec(self)
      end
      alias :have_action :have_actions

    end
  end
end
