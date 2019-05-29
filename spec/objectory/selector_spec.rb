require 'objectory/selector'

describe Objectory::Selector do
  subject { Objectory::Selector.new(path) }

  #
  # NOTE: Examples are ordered from more specific to more generic.
  #       The most generic selector is any selector, i.e. `.`.
  #       The least generic selector is null selector, i.e. `nil`
  #       or ``.
  #
  null = [nil, ''].freeze
  any = ['.'].freeze
  examples = ['.foo.bar.baz', '.foo.bar', '.foo'].freeze
  disjoint_examples = ['.foo.bar', '.foo.baz', '.bar'].freeze
  invalid = ['..', '?', '.foo[0]', '.foo.*'].freeze

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
      expect(evaluate(null + examples + any, :subset?)).to all(be_truthy)
    end

    it 'should be superset of nothing but itself' do
      expect(evaluate(null, :superset?)).to all(be_truthy)
      expect(evaluate(examples, :superset?)).to all(be_falsey)
    end

    it 'should not have intersect with anything' do
      expect(evaluate(null + examples + any, :intersect)).to all(be_nil)
    end
  end

  context 'with `.` initial value' do
    let(:path) { '.' }

    it 'should be equal to `.`' do
      expect(subject).to eq '.'
    end

    it 'should not have any subset but itself' do
      expect(evaluate(any, :subset?)).to all(be_truthy)
      expect(evaluate(null + examples, :subset?)).to all(be_falsey)
    end

    it 'should be superset of everything including itself' do
      expect(evaluate(null + examples + any, :superset?)).to all(be_truthy)
    end

    it 'should have intersect with everything except null' do
      expect(evaluate(examples + any, :intersect)).to eq examples + any
      expect(evaluate(null, :intersect)).to all(be_nil)
    end
  end

  examples.each_with_index do |example, i|
    context "with `#{example}` initial value" do
      let(:path) { example }

      more_generic = examples[i + 1..-1] + any
      more_specific = i > 0 ? examples[0..i - 1] : []

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

      it 'should be subset, superset, and intersect of itself' do
        expect(subject.subset?(subject)).to be_truthy
        expect(subject.superset?(subject)).to be_truthy
        expect(subject.intersect(subject)).to eq subject
      end
    end
  end

  describe :intersect do
    it 'should be symmetric' do
      a = Objectory::Selector.new examples[0]
      b = Objectory::Selector.new examples[1]
      expect(a.intersect(b) == b.intersect(a)).to be_truthy
    end

    it 'should return null for disjoint selectors' do
      disjoints = disjoint_examples.map { |s| Objectory::Selector.new s }
      disjoints.each do |i|
        disjoints.each do |j|
          if i == j
            expect(i.intersect(j)).to eq i
          else
            expect(i.intersect(j)).to be_nil
            expect(j.intersect(i)).to be_nil
          end
        end
      end
    end
  end

  describe [:subset?, :superset?] do
    it 'should return false for disjoint selectors' do
      disjoints = disjoint_examples.map { |s| Objectory::Selector.new s }
      disjoints.each do |i|
        disjoints.each do |j|
          expect(i.subset?(j)).to eq i == j
          expect(j.subset?(i)).to eq i == j
        end
      end
    end
  end

  invalid.each do |example|
    context "with `#{example}` value" do
      it 'should throw an exception' do
        expect { Objectory::Selector.new example }.to \
          raise_error(/not a valid path/)
      end
    end
  end
end
