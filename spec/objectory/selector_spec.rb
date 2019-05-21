require 'objectory/selector'

describe Objectory::Selector do
  subject { Objectory::Selector.new(path) }

  #
  # NOTE: Examples are ordered from more specific to more generic.
  #       The most generic selector is ALL selector, i.e. `.`.
  #       The least generic selector is NULL selector, i.e. `nil`
  #       or ``.
  #
  NULL = [nil, ''].freeze
  ANY = ['.'].freeze
  EXAMPLES = ['.foo.bar.baz', '.foo.bar', '.foo'].freeze
  DISJOINT_EXAMPLES = ['.foo.bar', '.foo.baz', '.bar'].freeze
  INVALID = ['..', '?', '.foo[0]', '.foo.*'].freeze

  def evaluate(samples, method)
    samples.map do |sample|
      subject.send(method, sample)
    end
  end

  context 'an instance' do
    let(:path) { '' }

    it 'should be a String' do
      expect(subject).to be_a String
    end

    it 'should support subset?, superset?, and intersect methods' do
      expect(subject).to respond_to :subset?
      expect(subject).to respond_to :superset?
      expect(subject).to respond_to :intersect
    end
  end

  context 'with a `nil` initial value' do
    let(:path) { nil }

    it 'should be empty' do
      expect(subject).to be_empty
    end

    it 'should be subset of everything including itself' do
      expect(evaluate(NULL + EXAMPLES + ANY, :subset?)).to all(be_truthy)
    end

    it 'should be superset of nothing but itself' do
      expect(evaluate(NULL, :superset?)).to all(be_truthy)
      expect(evaluate(EXAMPLES, :superset?)).to all(be_falsey)
    end

    it 'should not have intersect with anything' do
      expect(evaluate(NULL + EXAMPLES + ANY, :intersect)).to all(be_nil)
    end
  end

  context 'with `.` initial value' do
    let(:path) { '.' }

    it 'should be equal to `.`' do
      expect(subject).to eq '.'
    end

    it 'should not have any subset but itself' do
      expect(evaluate(ANY, :subset?)).to all(be_truthy)
      expect(evaluate(NULL + EXAMPLES, :subset?)).to all(be_falsey)
    end

    it 'should be superset of everything including itself' do
      expect(evaluate(NULL + EXAMPLES + ANY, :superset?)).to all(be_truthy)
    end

    it 'should have intersect with everything except null' do
      expect(evaluate(EXAMPLES + ANY, :intersect)).to eq EXAMPLES + ANY
      expect(evaluate(NULL, :intersect)).to all(be_nil)
    end
  end

  EXAMPLES.each_with_index do |example, i|
    context "with `#{example}` initial value" do
      let(:path) { example }

      more_generic = EXAMPLES[i + 1..-1] + ANY
      more_specific = i > 0 ? EXAMPLES[0..i - 1] : []

      it "should be equal to `#{example}`" do
        expect(subject).to eq example
      end

      it 'should be a subset of more generic examples' do
        expect(evaluate(more_generic, :subset?)).to all(be_truthy)
      end

      it 'should not be a subset of more specific examples' do
        expect(evaluate(more_generic, :subset?)).to all(be_truthy)
      end

      it 'should be a superset of more specific examples' do
        expect(evaluate(more_specific, :superset?)).to all(be_truthy)
      end

      it 'should not be a superset of more generic examples' do
        expect(evaluate(more_generic, :superset?)).to all(be_falsey)
      end

      it 'should have intersection with more specific examples' do
        expect(evaluate(more_specific, :intersect)).to eq more_specific
      end

      it 'should have intersection with more generic examples' do
        expect(evaluate(more_generic, :intersect)).to eq \
          [subject] * more_generic.length
      end
    end
  end

  context 'intersect operator' do
    it 'should be symmetric' do
      a = Objectory::Selector.new EXAMPLES[0]
      b = Objectory::Selector.new EXAMPLES[1]
      expect(a.intersect(b) == b.intersect(a)).to be_truthy
    end

    it 'should return nil for disjoint selectors' do
      disjoints = DISJOINT_EXAMPLES.map { |s| Objectory::Selector.new s }
      disjoints.each do |i|
        disjoints.each do |j|
          expect(i.intersect(j)).to be_nil
          expect(j.intersect(i)).to be_nil
        end
      end
    end
  end

  context 'subset and superset operators' do
    it 'should return false for disjoint selectors' do
      disjoints = DISJOINT_EXAMPLES.map { |s| Objectory::Selector.new s }
      disjoints.each do |i|
        disjoints.each do |j|
          expect(i.subset?(j)).to be_falsey
          expect(j.subset?(i)).to be_falsey
        end
      end
    end
  end

  INVALID.each do |example|
    context "with `#{example}` value" do
      it 'should throw an exception' do
        expect { Objectory::Selector.new example }.to \
          raise_error(/not a valid path/)
      end
    end
  end
end
