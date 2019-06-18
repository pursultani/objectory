require_relative 'selector'

module Objectory
  module SelectorEvaluator

    def evaluate(domain, selector, &block)
      do_evaluate(domain, selector, block, :read)
    end

    def evaluate!(domain, selector, &block)
      do_evaluate(domain, selector, block, :override)
    end

    private

    def do_evaluate(domain, selector, computer, mode = :read)
      return nil if selector.nil? || selector.empty?

      cursor = domain
      elements = parse(selector)

      # Find the leaf element.
      elements.each_index do |i|

        # The last element is the leaf.
        break if i == elements.length - 1

        # Traverse until arriving to the leaf element.
        parent = cursor
        cursor = value_of(cursor, elements[i])

        check_missing(cursor, selector, elements[i])

        # The leaf element is nil anyway. Break immediately.
        break if cursor.nil? && mode == :read

        # Value is missing. Add an empty Hash and proceed.
        cursor = value_of(parent, elements[i], {}) if cursor.nil?
      end

      # Use the leaf element.
      value = value_of(cursor, elements.last)

      if mode == :read
        computer.call(value)
      else
        value_of(cursor, elements.last, computer.call(value))
      end
    end

    def parse(selector)
      selector = Selector.new selector unless selector.is_a? Selector
      selector[1..-1].split('.')
    end

    def value_of(cursor, element, value = nil)
      return nil if cursor.nil?

      raise ArgumentError, 'Only Hash type is supported' \
        unless cursor.is_a? Hash

      if value.nil?
        element.nil? ? cursor : cursor[element]
      elsif element.nil?
        cursor.replace(value)
      else
        cursor[element] = value
      end
    end

    def check_missing(cursor, selector, element)
      return unless cursor.nil? && options[:strict]

      # Can not proceed any further if not lenient.
      raise ArgumentError,
            "Missing object `#{element}` in `#{selector}`." \
    end

  end
end
