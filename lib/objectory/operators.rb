require_relative 'errors'

module Objectory
  module Operators

    def self.operator(name, &block)
      desc = Descriptor.new name
      desc.instance_eval(&block)
      register(desc) if desc.check
    end

    class Descriptor

      attr_reader :parameters, :handlers

      def initialize(name, namespace = :default)
        @name = name
        @namespace = namespace
        @aliases = []
        @parameters = {}
        @handlers = {}
      end

      def check
        true
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
          @parameters[name]
        else
          options = values.last.is_a?(Hash) ? values.pop : {}
          @parameters[name] = {
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
        on(:error, *options, &block)
      end

      def on(name, *options, &block)
        @handlers[name] = {
          options: options,
          block: block
        }
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

    def self.register(desc)
      Pool.instance(desc.namespace).add desc
    end

    def self.unregister(desc)
      Pool.instance(desc.namespace).delete desc
    end

    def self.lookup(name, namespace = :default)
      Pool.instance(namespace).get(name)
    end

  end
end
