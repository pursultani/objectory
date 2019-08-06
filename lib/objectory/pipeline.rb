require_relative 'operators'

module Objectory
  class Pipeline

    attr_reader :name, :calls

    def initialize(name)
      @name = name
      @calls = []
    end

    def add_operator(operator, arguments = {}, index = -1)
      @calls.insert(index, Call.new(operator, arguments))
    end

    def remove_operator(index = -1)
      @calls.delete_at(index)
    end

    def execute(input, context)
      current = input
      @calls.each do |call|
        runtime = Objectory::Operators::Runtime.new(
          call.operator, context, call.arguments, input
        )
        current = runtime.run
      rescue StandardError => e
        context.report(e)
      end
      current
    end

    Call = Struct.new(:operator, :arguments)

  end
end
