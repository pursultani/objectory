require_relative 'errors'
require_relative 'selector_container'

module Objectory
  class Writer

    include SelectorContainer

    attr_reader :selectors

    def initialize(*selectors)
      @selectors = from(selectors)
    end

    def write(context, *values)
      raise Errors::WriteError,
            'The number of values does not match the number of selectors, ' \
            "expected #{@selectors.length}, got #{values.length}" \
            if @selectors.length != values.length

      @selectors.map.with_index do |selector, i|
        context.set(selector, values[i])
      end
    end

  end
end
