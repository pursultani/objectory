require 'objectory/operators'

module Objectory::Operators

  operator :constant do
    namespace :default
    aliases :const, :C
    input NilClass
    output Object
    parameter :value, Object

    validate do
      raise ArgumentError, '`value` is required' \
        if arguments[:value].nil?
    end

    execute do
      arguments[:value]
    end
  end

  operator :foo do
    aliases :F
    input Object
    output String
    parameter :prefix, String
    parameter :suffix, String

    validate do
      raise ArgumentError, 'At least one of `prefix` or `suffix` is required.' \
        if arguments[:prefix].nil? && arguments[:suffix].nil?
    end

    execute do
      (arguments[:prefix] || '') + arguments[:input].to_s +
        (arguments[:suffix] || '')
    end
  end

end
