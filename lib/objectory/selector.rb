module Objectory
  class Selector < String

    def initialize(path)
      super(validate(path.to_s))
    end

    def null?
      empty?
    end

    def subset?(other)
      return true if empty?
      return false if other.nil? || other.empty?

      with_prefix? other
    end

    def superset?(other)
      return other.nil? || other.empty? if empty?
      return true if other.nil? || other.empty?

      with_prefix? self, other
    end

    def intersect(other)
      return if empty? || other.nil? || other.empty?

      if with_prefix? other
        self
      elsif with_prefix? self, other
        other
      end
    end

    private

    def with_prefix?(other, subject = self)
      other == subject || subject.start_with?(other == '.' ? other : other + '.')
    end

    def validate(path)
      return '' unless path
      return path if path.empty? || path == '.'

      raise ArgumentError, "`#{path}` is not a valid path" \
        unless /^(\.\w+)*$/ =~ path

      path
    end

  end
end
