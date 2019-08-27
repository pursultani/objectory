require_relative 'errors'

module Objectory
  module Operators

    class Descriptor

      attr_reader :signature, :handlers

      def initialize(name, namespace = :default)
        @name = name
        @namespace = namespace
        @aliases = []
        @signature = {}
        @handlers = {}
      end

      def check
        check_name
        check_signature
        check_handlers
        self
      end

      def name(*values)
        if values.empty?
          @name
        else
          @name = values.first
        end
      end

      def namespace(*values)
        if values.empty?
          @namespace
        else
          @namespace = values.first
        end
      end

      def aliases(*values)
        if values.empty?
          @aliases
        else
          @aliases = values
        end
      end

      def input(*values)
        parameter(:input, *values)
      end

      def output(*values)
        parameter(:output, *values)
      end

      def parameter(name, *values)
        if values.empty?
          @signature[name]
        else
          options = values.last.is_a?(Hash) ? values.pop : {}
          @signature[name] = {
            types: values.empty? ? [Object] : values,
            options: options
          }
        end
      end

      def validate(&block)
        on(:validate, &block)
      end

      def execute(&block)
        on(:execute, &block)
      end

      def error(*options, &block)
        options = [StandardError] if options.length.zero?
        on(:error, *options, &block)
      end

      def on(name, *options, &block)
        @handlers[name] = {
          options: options || [],
          block: block
        }
      end

      private

      def check_name
        raise Objectory::Errors::CompilerError,
              'Operator name is required' \
              if @name.nil?

        raise Objectory::Errors::CompilerError,
              'Operator namespace is required' \
              if @namespace.nil?
      end

      def check_signature
        @signature.each_pair do |name, sig|
          raise Objectory::Errors::CompilerError,
                "Parameter `#{@namespace}:#{@name}#{name}` " \
                'uses a non-Class type' \
                if sig[:types].any? { |type| !type.instance_of? Class }

          raise Objectory::Errors::CompilerError,
                "Parameter `#{@namespace}:#{@name}#{name}` options are nil" \
                if sig[:options].nil?
        end
      end

      def check_handlers
        raise Objectory::Errors::CompilerError,
              'At least one handler is required' \
              if @handlers.empty?
      end

    end

    class Pool

      attr_reader :namespace, :descriptors

      def initialize(namespace)
        @namespace = namespace || :default
        @descriptors = {}
      end

      def add(desc)
        raise Objectory::Errors::CompilerError,
              "Operator `#{desc.namespace}:#{desc.name}` does not " \
              "belong to `#{@namespace}` namespace." \
              if desc.namespace != @namespace

        raise Objectory::Errors::CompilerError,
              "Operator `#{@namespace}:#{desc.name}` already exists." \
              if @descriptors.key? desc.name

        desc.aliases.each do |name|
          raise Objectory::Errors::CompilerError,
                "Alias `#{@namespace}:#{name}` already exists." \
                if @descriptors.key? name
        end

        @descriptors[desc.name] = desc
        desc.aliases.each do |name|
          @descriptors[name] = desc
        end
      end

      def delete(desc)
        @descriptors.delete_if do |name, _desc|
          name == desc.name || desc.aliases.include?(name)
        end
      end

      def get(name)
        desc = @descriptors[name]

        raise Objectory::Errors::CompilerError,
              "Operator `#{@namespace}:#{name}` not found." \
              if desc.nil?

        desc
      end

      def nuke(safety)
        @descriptors.clear if safety
      end

      @@pools = {}

      def self.instance(namespace)
        result = @@pools[namespace]
        if result.nil?
          result = Pool.new namespace
          @@pools[namespace] = result
        end
        result
      end

    end

    class Runtime

      attr_reader :context, :arguments

      def initialize(ref, context, arguments, input)
        @descriptor = ref.is_a?(Descriptor) ? ref : Operators.find(ref)
        @context = context
        @arguments = arguments || {}
        @arguments[:input] = input
      end

      def name
        @descriptor.name
      end

      def namespace
        @descriptor.namespace
      end

      def signature
        @descriptor.signature
      end

      def run
        handle(:validate)
        handle(:execute)
      rescue StandardError => e
        err_handler = @descriptor.handlers[:error]
        err_handled = false

        unless err_handler.nil?
          err_handler[:options]&.each do |err_type|
            next unless e.is_a? err_type
            break if err_handled

            err_handled = !handle(:error, [e]).nil?
          end
        end

        raise e unless err_handled
      end

      private

      def handle(event, options = nil)
        handler = @descriptor.handlers[event]
        return nil if handler.nil? || handler[:block].nil?

        instance_exec(*(options || handler[:options] || []), &handler[:block])
      end

    end

    def self.operator(name, &block)
      desc = Descriptor.new name
      desc.instance_exec(&block)
      register(desc.check)
    end

    def self.register(desc)
      Pool.instance(desc.namespace).add desc
    end

    def self.unregister(desc)
      Pool.instance(desc.namespace).delete desc
    end

    def self.lookup(name, namespace = :default)
      Pool.instance(namespace).get(name)
    end

    def self.find(ref)
      q = ref.to_s.split ':'
      name = (q.length > 1 ? q.last : q.first).to_sym
      namespace = q.length > 1 ? q[0..-2].join(':').to_sym : :default
      lookup(name, namespace)
    end

  end
end
