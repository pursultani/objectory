require_relative 'errors'

module Objectory
  class Descriptor

    attr_reader :mappings

    def initialize
      @mappings = []
    end

    def add(name, &block)
      mapping = Mapping.new(name, self)
      mapping.instance_exec(&block)
      @mappings << mapping.validate
    end

    def remove(index = -1)
      @mappings.delete_at(index)
    end

    def reset
      @mappings = []
    end

    def validate
      # check and throw exception
      self
    end

  end

  class Mapping

    attr_reader :name, :endpoints, :pipeline

    def initialize(name, descriptor)
      @name = name
      @descriptor = descriptor
      @endpoints = {}
      @pipeline = Objectory::Pipeline.new name
    end

    def from(selector)
      @endpoints[:from] = selector
    end

    def to(selector)
      @endpoints[:to] = selector
    end

    def through(pipeline)
      @pipeline = pipeline
    end

    def call(operator, arguments = {})
      @pipeline.add(operator, arguments)
    end

    def validate
      raise Objectory::Errors::CompilerError,
            "A non-empty pipeline is required for mapping `#{@name}`" \
            if @pipeline.nil? || @pipeline.calls.empty?

      raise Objectory::Errors::CompilerError,
            "Mapping `#{@name}` does not have a target" \
            if @endpoints[:to].nil?

      raise Objectory::Errors::CompilerError,
            "Pipeline `#{@pipeline.name}` already exists" \
            if @descriptor.mappings.find do |m|
              m.pipeline.name == @pipeline.name
            end
      self
    end

  end
end
