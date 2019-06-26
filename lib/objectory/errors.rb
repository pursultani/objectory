module Objectory
  module Errors

    class CompilerError < StandardError
    end

    class RuntimeError < StandardError
    end

    class ReadError < RuntimeError
    end

    class WriteError < RuntimeError
    end

    class RuntimeErrorContainer < RuntimeError

      attr_reader :errors

      def initialize(errors, message = nil)
        super(message || default_message(errors))
        @errors = errors
      end

      private

      def default_message(errors)
        "#{errors.length > 1 ? 'Multiple errors' : 'An error'} " \
        'occurred at runtime'
      end

    end

  end
end
