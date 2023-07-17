RSpec.describe OpenapiContracts::Doc::Path do
  subject(:path) { doc.with_path('/messages/{id}') }

  let(:doc) { OpenapiContracts::Doc.new(schema) }
  let(:schema) do
    {
      'paths' => {
        '/messages/{id}' => {
          'parameters' => [id_param].compact
        }
      }
    }
  end
  let(:id_param) do
    {
      'name'     => 'id',
      'in'       => 'path',
      'required' => true,
      'schema'   => id_schema
    }
  end
  let(:id_schema) { {} }

  describe '#dynamic?' do
    subject { path.dynamic? }

    it { is_expected.to be true }
  end

  describe '#static?' do
    subject { path.static? }

    it { is_expected.to be false }
  end

  describe '#matches?(path, method)' do
    context 'when the param is a string with pattern' do
      let(:id_schema) do
        {
          'type'    => 'string',
          'pattern' => '^[a-f,0-9]{8}$'
        }
      end

      it 'can match', :aggregate_failures do
        expect(path.matches?('/messages/1234abcd', 'get')).to be true
        expect(path.matches?('/messages/123', 'get')).to be false
      end
    end

    context 'when the param is a string with length' do
      let(:id_schema) do
        {
          'type'      => 'string',
          'minLength' => 4,
          'maxLength' => 8
        }
      end

      it 'can match', :aggregate_failures do
        expect(path.matches?('/messages/1234', 'get')).to be true
        expect(path.matches?('/messages/12', 'get')).to be false
        expect(path.matches?('/messages/123456789', 'get')).to be false
      end
    end

    context 'when the param is a integer from 0 - 1000' do
      let(:id_schema) do
        {
          'type'    => 'integer',
          'minimum' => 0,
          'maximum' => 1000
        }
      end

      it 'can match', :aggregate_failures do
        expect(path.matches?('/messages/1001', 'get')).to be false
        expect(path.matches?('/messages/1000', 'get')).to be true
        expect(path.matches?('/messages/1.234', 'get')).to be false
        expect(path.matches?('/messages/-1234', 'get')).to be false
        expect(path.matches?('/messages/-1.234', 'get')).to be false
      end
    end

    context 'when the param is a number from 0 to 1000' do
      let(:id_schema) do
        {
          'type'             => 'number',
          'minimum'          => 0,
          'maximum'          => 1000,
          'exclusiveMaximum' => true
        }
      end

      it 'can match', :aggregate_failures do
        expect(path.matches?('/messages/1000', 'get')).to be false
        expect(path.matches?('/messages/999.9', 'get')).to be true
        expect(path.matches?('/messages/1.234', 'get')).to be true
        expect(path.matches?('/messages/word', 'get')).to be false
        expect(path.matches?('/messages/-1.234', 'get')).to be false
      end
    end
  end

  describe '#parameters' do
    subject { path.parameters }

    it 'returns a parsed list of path-wide parameters' do
      expect(subject).to be_a(Enumerable)
      expect(subject.size).to eq(1)
      subject.first.then do |param|
        expect(param).to be_a(OpenapiContracts::Doc::Parameter)
        expect(param.name).to eq('id')
        expect(param).to be_in_path
      end
    end
  end
end
