require_relative 'selector'

module Objectory
  module SelectorContainer

    def from(values)
      raise ArgumentError, 'At least one selector is required' \
        if values.empty?

      values.collect do |value|
        value.is_a?(Selector) ? value : Selector.new(value)
      end
    end

    def empty?
      selectors.empty?
    end

    def depends_on?(other)
      return false if other.nil?

      other_selectors = other.is_a?(SelectorContainer) ? \
        other.selectors : from(other)

      selectors.each do |i|
        other_selectors.each do |j|
          return true unless i.intersect(j).nil?
        end
      end

      false
    end

  end
end
