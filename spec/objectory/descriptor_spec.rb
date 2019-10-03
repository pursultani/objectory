require 'objectory/descriptor'
require 'objectory/pipeline'

describe Objectory::Descriptor do
  it 'should add a new mapping and describe it with the specified calls' do
    subject.add :test do
      from '.foo'
      to '.bar'
      call :foo, value: 'FOO'
      call :bar, value: 'BAR'
    end
    expect(subject.mappings.length).to eq 1
    expect(subject.mappings[0].name).to eq :test
    expect(subject.mappings[0].endpoints).to eq(from: '.foo', to: '.bar')
    expect(subject.mappings[0].pipeline.name).to eq :test
    expect(subject.mappings[0].pipeline.calls.length).to eq 2
    expect(subject.mappings[0].pipeline.calls[0].operator).to eq :foo
    expect(subject.mappings[0].pipeline.calls[0].arguments).to eq(value: 'FOO')
    expect(subject.mappings[0].pipeline.calls[1].operator).to eq :bar
    expect(subject.mappings[0].pipeline.calls[1].arguments).to eq(value: 'BAR')
  end

  it 'should add a new mapping and describe it with the specified calls' do
    pipeline = Objectory::Pipeline.new :test
    pipeline.add :foo, value: 'FOO'
    pipeline.add :bar, value: 'BAR'
    subject.add :test do
      from '.foo'
      to '.bar'
      through pipeline
    end
    expect(subject.mappings.length).to eq 1
    expect(subject.mappings[0].name).to eq :test
    expect(subject.mappings[0].endpoints).to eq(from: '.foo', to: '.bar')
    expect(subject.mappings[0].pipeline.name).to eq :test
    expect(subject.mappings[0].pipeline.calls.length).to eq 2
    expect(subject.mappings[0].pipeline.calls[0].operator).to eq :foo
    expect(subject.mappings[0].pipeline.calls[0].arguments).to eq(value: 'FOO')
    expect(subject.mappings[0].pipeline.calls[1].operator).to eq :bar
    expect(subject.mappings[0].pipeline.calls[1].arguments).to eq(value: 'BAR')
  end

  it 'should throw an error when pipeline is empty' do
    expect do
      subject.add :test do
        from '.foo'
        to '.bar'
      end
    end.to raise_error Objectory::Errors::CompilerError
  end

  it 'should throw an error when pipeline does not have target' do
    expect do
      subject.add :test do
        from '.foo'
        call :foo, value: 'FOO'
        call :bar, value: 'BAR'
      end
    end.to raise_error Objectory::Errors::CompilerError
  end

  it 'should be ok when pipeline does not have source' do
    subject.add :test do
      from '.foo'
      to '.bar'
      call :foo, value: 'FOO'
      call :bar, value: 'BAR'
    end
    expect(subject.mappings.length).to eq 1
  end
end
