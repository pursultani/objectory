require_relative 'operators'

module Objectory
  class Pipeline

    attr_reader :name, :calls

    def initialize(name)
      @name = name
      @calls = []
    end

    def add(operator, arguments = {}, index = -1)
      @calls.insert(index, Call.new(operator, arguments))
    end

    def remove(index = -1)
      @calls.delete_at(index)
    end

    def execute(context, input = nil)
      current = input
      @calls.each do |call|
        runtime = Objectory::Operators::Runtime.new(
          call.operator, context, call.arguments, current
        )
        output = runtime.run
        current = output
      rescue StandardError => e
        context.catch(e)
      end
      current
    end

    Call = Struct.new(:operator, :arguments)

  end
end
