require 'objectory/version'

describe Objectory::Version do
  subject { Objectory::Version.new(version) }

  context 'with initial value' do
    let(:version) { '1.0-init-value' }

    it 'should pick the initial value' do
      expect(subject.to_s).to eq '1.0-init-value'
    end
  end

  context 'with environment variable' do
    let(:version) { nil }

    it 'should pick the environment variable' do
      allow(ENV).to receive(:[])
        .with('OBJECTORY_VERSION')
        .and_return('1.0-env')
      expect(subject.to_s).to eq '1.0-env'
    end
  end

  context 'with version file' do
    let(:version) { nil }

    it 'should pick the file content' do
      allow(File).to receive(:read)
        .and_return('1.0-file')
      expect(subject.to_s).to eq '1.0-file'
    end
  end
end
