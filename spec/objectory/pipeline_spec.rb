require 'objectory/pipeline'
require 'objectory/context'
require_relative './operator_examples'

describe Objectory::Pipeline do
  context :empty do
    subject { Objectory::Pipeline.new('empty') }

    it 'should use the specified name' do
      expect(subject.name).to eq 'empty'
    end

    it 'should not have any operator call' do
      expect(subject.calls).to be_empty
    end
  end

  context :basic do
    subject do
      pipeline = Objectory::Pipeline.new('basic')
      pipeline.add(:C, value: 'FOO')
      pipeline.add(:foo, prefix: 'BEFORE-', suffix: '-AFTER')
      pipeline.add(:F, prefix: 'BEGIN-', suffix: '-END')
      pipeline
    end

    let(:context) { Objectory::Context.new({}, {}) }

    it 'should contain calls to specified operators' do
      expect(subject.calls.length).to eq 3
      result = subject.execute(context)
      expect(context.error).to be_nil
      expect(result).to eq 'BEGIN-BEFORE-FOO-AFTER-END'
    end
  end

  context :error do
    subject do
      pipeline = Objectory::Pipeline.new('error')
      pipeline.add(:C, value: 'FOO')
      pipeline.add(:foo, prefix: 'BEFORE-', suffix: '-AFTER')
      pipeline.add(:F)
      pipeline
    end

    let(:context) { Objectory::Context.new({}, {}) }

    it 'should capture errors and return an incomplete result' do
      expect(subject.calls.length).to eq 3
      result = subject.execute(context)
      expect(result).to eq 'BEFORE-FOO-AFTER'
      expect(context.error).to be_a Objectory::Errors::RuntimeErrorContainer
      expect(context.error.message).to match(/an error occurred at runtime/i)
    end
  end
end
