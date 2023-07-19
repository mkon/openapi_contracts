RSpec.describe OpenapiContracts::PayloadParser do
  describe '.parse(media_type, raw_body)' do
    subject { described_class.parse(media_type, raw_body) }

    context 'when the media-type is application/json' do
      let(:media_type) { 'application/json' }
      let(:raw_body) { '{"hello":"world"}' }

      it 'parses correctly' do
        expect(subject).to be_a(Hash)
        expect(subject).to eq('hello' => 'world')
      end
    end

    context 'when the media-type is application/vnd.api+json' do
      let(:media_type) { 'application/vnd.api+json' }
      let(:raw_body) { '{"hello":"world"}' }

      it 'parses correctly' do
        expect(subject).to be_a(Hash)
        expect(subject).to eq('hello' => 'world')
      end
    end

    context 'when the media-type is application/x-www-form-urlencoded' do
      let(:media_type) { 'application/x-www-form-urlencoded' }
      let(:raw_body) { 'hello=world' }

      it 'parses correctly' do
        expect(subject).to be_a(Hash)
        expect(subject).to eq('hello' => 'world')
      end
    end

    context 'when the media-type is application/x-www-form-urlencoded with Array' do
      let(:media_type) { 'application/x-www-form-urlencoded' }
      let(:raw_body) { 'hello[]=world&hello[]=foo' }

      it 'parses correctly' do
        expect(subject).to be_a(Hash)
        expect(subject).to eq('hello' => %w(world foo))
      end
    end
  end
end
