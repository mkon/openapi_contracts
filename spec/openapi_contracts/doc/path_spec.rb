RSpec.describe OpenapiContracts::Doc::Path do
  subject(:path) { doc.with_path('/messages/{id}') }

  let(:doc) { OpenapiContracts::Doc.new(schema) }
  let(:schema) do
    {
      'paths' => {
        '/messages/{id}' => {
          'parameters' => [id_param].compact
        },
        '/messages/{id}/{second_id}' => {
          'parameters' => [id_param, second_id_param].compact
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

  let(:second_id_param) do
    {
      'name'     => 'second_id',
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

  describe "#path_regexp" do
    subject { doc.with_path("/messages/{id}/{second_id}").path_regexp.match("/messages/123/abc").captures }

    it "matches both parameters" do
      expect(subject).to eq(["123", "abc"])
    end
  end
end
