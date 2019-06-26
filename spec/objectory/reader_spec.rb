require 'objectory/reader'
require 'objectory/context'

describe Objectory::Reader do
  subject { Objectory::Reader.new(*selectors) }
  let(:domain) { { 'foo' => { 'bar' => 'FOOBAR' } } }
  let(:sample) { sample = Objectory::Context.new(domain, nil, options) }

  context :lenient do
    let(:selectors) { ['.foo.bar', '.bar', '.bar.baz'] }
    let(:options) { {} }

    it 'should read the existing values and return nil for missing' do
      expect(subject.read(sample)).to eq ['FOOBAR', nil, nil]
    end
  end

  context :strict do
    let(:selectors) { ['.foo.bar', '.bar', '.bar.baz'] }
    let(:domain) { { 'foo' => { 'bar' => 'FOOBAR' }, 'bar' => {} } }
    let(:options) { { strict: true } }

    it 'should return nil for missing attributes of existing objects' do
      expect(subject.read(sample)).to eq ['FOOBAR', {}, nil]
    end
  end

  context ':strict error' do
    let(:selectors) { ['.bar.baz'] }
    let(:options) { { strict: true } }

    it 'should raise error for attributes of missing objects' do
      expect { subject.read(sample) }.to raise_error(/Missing object/)
    end
  end
end
