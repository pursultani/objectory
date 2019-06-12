require_relative 'errors'
require_relative 'selector_evaluator'

module Objectory
  class Context

    include SelectorEvaluator

    attr_reader :objects, :parameters, :options

    def initialize(objects, parameters, options = {})
      raise ArgumentError, 'Only Hash type is supported' \
        unless objects.nil? || objects.is_a?(Hash)

      @objects = objects || {}
      @parameters = parameters || {}
      @options = options
      @errors = []
    end

    def get(path)
      evaluate(@objects, path) { |value| value }
    end

    def set(path, value)
      evaluate!(@objects, path) { value }
    end

    def error?
      !@errors.empty?
    end

    def error
      @errors.empty? ? nil : Errors::RuntimeErrorContainer.new(@errors)
    end

    def catch(error)
      @errors << error
    end

  end
end
