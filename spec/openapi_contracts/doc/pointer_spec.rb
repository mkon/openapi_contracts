RSpec.describe OpenapiContracts::Doc::Pointer do
  subject(:pointer) { described_class.new(segments) }

  let(:segments) { %w(foo bar) }

  describe '#inspect' do
    subject { pointer.inspect }

    it { is_expected.to eq '<OpenapiContracts::Doc::Pointer["foo", "bar"]>' }
  end

  describe '#parent' do
    subject { pointer.parent }

    it { is_expected.to eq described_class['foo'] }
  end
end
