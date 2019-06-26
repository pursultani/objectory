require_relative 'selector_container'

module Objectory
  class Reader

    include SelectorContainer

    attr_reader :selectors

    def initialize(*selectors)
      @selectors = from(selectors)
    end

    def read(context)
      case @selectors.length
      when 0
        nil
      when 1
        context.get @selectors[0]
      else
        @selectors.collect { |selector| context.get(selector) }
      end
    end

  end
end
