module Remarkable
  module ActiveRecord
    module Matchers
      class AllowValuesForMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :attributes, :as => :attribute

        optional :message
        optional :in, :splat => true
        optional :allow_nil, :allow_blank, :default => true

        collection_assertions :is_valid?, :is_invalid?, :allow_nil?, :allow_blank?

        default_options :message => :invalid

        before_assert do
          first_value = @options[:in].is_a?(Array) ? @options[:in].first : @options[:in]
          @in_range = first_value.is_a?(Range)

          @options[:in] = if @in_range
            first_value.to_a[0,2] + first_value.to_a[-2,2]
          else
            [*@options[:in]].compact
          end

          @options[:in].uniq!
        end

        protected

          def is_valid?
            valid_values.each do |value|
              return false, :value => value.inspect unless good?(value)
            end
            true
          end

          def is_invalid?
            invalid_values.each do |value|
              return false, :value => value.inspect unless bad?(value)
            end
            true
          end

          def valid_values
            @options[:in]
          end

          def invalid_values
            []
          end

          def interpolation_options
            options = if @in_range
              { :in => (@options[:in].first..@options[:in].last).inspect }
            elsif @options[:in].is_a?(Array)
              { :in => array_to_sentence(@options[:in], true, '[]') }
            else
              { :in => @options[:in].inspect }
            end

            options.merge!(:behavior => @behavior.to_s)
          end

      end

      # Ensures that the attribute can be set to the given values.
      #
      # Note: this matcher accepts at once just one attribute to test.
      # Note: this matcher is also aliased as "validate_format_of".
      #
      # == Options
      #
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # == Examples
      #
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #   should_not_allow_values_for :isbn, "bad 1", "bad 2"
      #
      #   it { should allow_values_for(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not allow_values_for(:isbn, "bad 1", "bad 2") }
      #
      def allow_values_for(attribute, *args, &block)
        options = args.extract_options!
        AllowValuesForMatcher.new(attribute, options.merge!(:in => args), &block).spec(self)
      end

      # Deprecated. Use allow_values_for instead.
      #
      def validate_format_of(*args)
        if caller[0] =~ /\macros.rb/
          warn "[DEPRECATION] should_validate_format_of is deprecated, use should_allow_values_for instead."
        else
          warn "[DEPRECATION] validate_format_of is deprecated, use allow_values_for instead. Called from #{caller[0]}."
        end
        allow_values_for(*args)
      end

    end
  end
end
