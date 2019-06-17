require 'objectory/context'

describe Objectory::Context do
  describe :objects do
    subject { Objectory::Context.new(objects, nil) }
    let(:objects) { {} }

    it 'should provide access to domain' do
      subject.objects[:foo] = 'FOO'
      expect(subject.objects).to eq(foo: 'FOO')
    end

    it 'should provide access to domain attributes' do
      expect(subject.get('.foo.bar')).to be_nil
      subject.set('.foo.bar', 'FOOBAR')
      expect(subject.get('.foo.bar')).to eq 'FOOBAR'
    end

    context 'nil initial value' do
      let(:objects) { nil }

      it 'should be an empty Hash' do
        expect(subject.objects).to be_a Hash
        expect(subject.objects).to be_empty
      end
    end

    context 'non-empty initial value' do
      let(:objects) { { foo: 'FOO' } }

      it 'should be the initial value' do
        expect(subject.objects).to eq(foo: 'FOO')
      end
    end

    context 'non-Hash initial value' do
      it 'should reject it' do
        expect { Objectory::Context.new(Struct.new(:foo, :bar), nil) }.to \
          raise_error(/Only Hash type is supported/)
      end
    end
  end

  describe :parameters do
    subject { Objectory::Context.new(nil, parameters) }

    context 'nil initial value' do
      let(:parameters) { nil }

      it 'should be an empty Hash' do
        expect(subject.objects).to be_a Hash
        expect(subject.objects).to be_empty
      end
    end

    context 'non-empty initial value' do
      let(:parameters) { { foo: 'FOO' } }

      it 'should be the initial value' do
        expect(subject.parameters).to eq(foo: 'FOO')
      end
    end
  end

  describe :errors do
    subject { Objectory::Context.new(nil, nil) }

    it 'should collect and return them in a container' do
      oops = StandardError.new('Oops!')
      uh_oh = StandardError.new('Uh-oh!')
      expect(subject.error?).to be_falsey
      subject.catch(oops)
      expect(subject.error?).to be_truthy
      expect(subject.error.to_s).to match(/an error/i)
      expect(subject.error.errors).to eq [oops]
      subject.catch(uh_oh)
      expect(subject.error.to_s).to match(/multiple errors/i)
      expect(subject.error.errors).to eq [oops, uh_oh]
    end
  end

  describe :options do
    context 'with no initial options' do
      subject { Objectory::Context.new(nil, nil) }

      it 'should be empty' do
        expect(subject.options).to be_empty
      end
    end

    context 'with initial options' do
      subject { Objectory::Context.new(nil, nil, strict: true, foo: :bar) }

      it 'should contain the initial options' do
        expect(subject.options).to eq({ strict: true, foo: :bar })
      end
    end
  end
end
