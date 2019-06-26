require 'objectory/writer'

describe Objectory::Writer do
  subject { Objectory::Writer.new(*selectors) }
  let(:domain) { { 'foo' => { 'bar' => '' } } }
  let(:sample) { Objectory::Context.new(domain, nil, options) }

  context :lenient do
    let(:selectors) { ['.foo.bar', '.foo.baz', '.bar'] }
    let(:options) { {} }

    it 'should overwrite existing attributes and add missing ones' do
      subject.write(sample, 'FOOBAR', 'FOOBAZ', 'BAR')
      expect(sample.objects).to eq(
        'foo' => {
          'bar' => 'FOOBAR',
          'baz' => 'FOOBAZ'
        },
        'bar' => 'BAR'
      )
    end

    it 'should raise error when the number of values and selectors mismatch' do
      expect { subject.write(sample, 1, 2) }.to \
        raise_error(Objectory::Errors::WriteError)
      expect { subject.write(sample, 1, 2, 3, 4) }.to \
        raise_error(Objectory::Errors::WriteError)
    end
  end

  context :strict do
    let(:options) { { strict: true } }
    let(:selectors) { ['.foo.bar', '.foo.baz', '.bar'] }

    it 'should overwrite or add attributes to existing objects' do
      subject.write(sample, 'FOOBAR', 'FOOBAZ', 'BAR')
      expect(sample.objects).to eq(
        'foo' => {
          'bar' => 'FOOBAR',
          'baz' => 'FOOBAZ'
        },
        'bar' => 'BAR'
      )
    end
  end

  context ':strict error' do
    let(:options) { { strict: true } }
    let(:selectors) { ['.bar.baz'] }

    it 'should raise error for attributes of missing objects' do
      expect { subject.write(sample, 'BARBAZ') }.to \
        raise_error(/Missing object/)
    end
  end
end
