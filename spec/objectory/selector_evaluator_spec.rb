require 'objectory/selector_evaluator'

class MockEvaluator

  include Objectory::SelectorEvaluator

  attr_reader :options

  def initialize(options = [])
    @options = options || []
  end

end

describe Objectory::SelectorEvaluator do
  subject { MockEvaluator.new options }
  let(:options) { [] }

  describe :evaluate do
    context :lenient do
      it 'should return nil for null and empty selectors' do
        domain = { 'foo' => 'FOO' }
        subject.evaluate(domain, nil) { |v| expect(v).to be_nil }
        subject.evaluate(domain, '') { |v| expect(v).to be_nil }
      end

      it 'should return the domain for `.` selector' do
        domain = { 'foo' => 'FOO', 'bar' => 'BAR' }
        subject.evaluate(domain, '.') { |v| expect(v).to eq domain }
      end

      it 'should select the existing objects' do
        domain = { 'foo' => 'FOO', 'bar' => { 'baz' => 'BAZ' } }
        subject.evaluate(domain, '.foo') { |v| expect(v).to eq 'FOO' }
        subject.evaluate(domain, '.bar.baz') { |v| expect(v).to eq 'BAZ' }
      end

      it 'should return nil for non-existing objects' do
        domain = { 'foo' => 'FOO' }
        subject.evaluate(domain, '.bar') { |v| expect(v).to be_nil }
        subject.evaluate(domain, '.bar.baz') { |v| expect(v).to be_nil }
      end
    end

    context :strict do
      let(:options) { [:strict] }

      it 'should raise an error for non-existing objects' do
        domain = { 'foo' => 'FOO' }
        subject.evaluate(domain, '.bar') { |v| expect(v).to be_nil }
        expect { subject.evaluate(domain, '.bar.baz') {} }.to \
          raise_error(/Missing object/)
        expect { subject.evaluate(domain, '.foo.bar') {} }.to \
          raise_error(/Only Hash types are supported/)
      end
    end
  end

  describe :evaluate! do
    context :lenient do
      it 'should drop the value for null and empty selectors' do
        domain = {}
        subject.evaluate!(domain, nil) { |_v| 'FOO' }
        subject.evaluate!(domain, '') { |_v| 'BAR' }
        expect(domain).to be_empty
      end

      it 'should override the domain for `.` selector' do
        domain = { 'foo' => 'FOO', 'bar' => 'BAR' }
        replacement = { 'baz' => 'BAZ' }
        subject.evaluate!(domain, '.') { |_v| replacement }
        expect(domain).to eq replacement
      end

      it 'should override the existing objects' do
        domain = { 'foo' => 'FOO', 'bar' => { 'baz' => 'BAZ' }, 'baz' => {} }
        subject.evaluate!(domain, '.foo') { |v| v + '2' }
        subject.evaluate!(domain, '.bar.baz') { |v| v + '2' }
        subject.evaluate!(domain, '.baz') { |_v| 'BAZ' }
        expect(domain).to eq(
          'foo' => 'FOO2', 'bar' => { 'baz' => 'BAZ2' }, 'baz' => 'BAZ'
        )
      end

      it 'should append non-existing objects' do
        domain = {}
        subject.evaluate!(domain, '.a.b.c') { 'ABC' }
        subject.evaluate!(domain, '.a.b.d') { 'ABD' }
        subject.evaluate!(domain, '.i.j') { 'IJ' }
        subject.evaluate!(domain, '.x') { 'X' }
        expect(domain).to eq(
          'a' => {'b' => { 'c' => 'ABC', 'd' => 'ABD' } },
          'i' => { 'j' => 'IJ' }, 'x' => 'X'
        )
      end
    end

    context :strict do
      let(:options) { [:strict] }

      it 'should raise an error for non-existing objects' do
        domain = {}
        subject.evaluate!(domain, '.foo') { 'FOO' }
        expect(domain).to eq('foo' => 'FOO')
        expect { subject.evaluate!(domain, '.bar.baz') {} }.to \
          raise_error(/Missing object/)
        expect { subject.evaluate!(domain, '.foo.bar') {} }.to \
          raise_error(/Only Hash types are supported/)
      end
    end
  end
end
