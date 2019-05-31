require 'objectory/selector_container'

class MockContainer

  include Objectory::SelectorContainer

  attr_reader :selectors

  def initialize(*selectors)
    @selectors = from(selectors)
  end

end

describe Objectory::SelectorContainer do

  empty = MockContainer.new('')
  any = MockContainer.new('.')
  joint_examples = [
    MockContainer.new('.foo.bar.baz'),
    MockContainer.new('.foo.bar', '.foo.baz'),
    MockContainer.new('.foo', '.bar')
  ]
  disjoint_examples = [
    MockContainer.new('.a.b', '.x.y'),
    MockContainer.new('.a.d', '.x.z'),
    MockContainer.new('.i.j', '.j')
  ]

  describe :depends_on? do
    it 'should always return false for null or empty containers' do
      ([empty, any] + joint_examples).each do |container|
        expect(container.depends_on?(nil)).to be_falsey
        expect(container.depends_on?(empty)).to be_falsey
        expect(empty.depends_on?(container)).to be_falsey
      end
    end

    it 'should always return true for a container with `.` selector' do
      ([any] + joint_examples).each do |container|
        expect(container.depends_on?(any)).to be_truthy
        expect(any.depends_on?(container)).to be_truthy
      end
    end

    it 'should return true for joint containers' do
      joint_examples.each do |i|
        joint_examples.each do |j|
          expect(i.depends_on?(j)).to be_truthy
        end
      end
    end

    it 'should return false for disjoint containers' do
      disjoint_examples.each do |i|
        disjoint_examples.each do |j|
          expect(i.depends_on?(j)).to eq i == j
        end
      end
    end

    it 'should be symmetric' do
      (joint_examples + disjoint_examples).each do |i|
        (joint_examples + disjoint_examples).each do |j|
          expect(i.depends_on?(j) == j.depends_on?(i)).to be_truthy
        end
      end
    end
  end
end
