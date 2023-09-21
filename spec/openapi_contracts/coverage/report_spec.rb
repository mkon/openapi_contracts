RSpec.describe OpenapiContracts::Coverage::Report do
  let(:doc) { OpenapiContracts::Doc.parse(openapi_dir) }
  let(:openapi_dir) { FIXTURES_PATH.join('openapi') }

  describe '.merge' do
    subject { described_class.merge(doc, report1, report2, report3) }

    let(:report1) do
      {
        '/user' => {
          'get' => {
            '200' => {
              'application/json' => 1
            }
          }
        }
      }
    end
    let(:report2) do
      {
        '/user' => {
          'get' => {
            '200' => {
              'application/json' => 2
            },
            '400' => {
              'text/html' => 2
            }
          }
        }
      }
    end
    let(:report3) do
      {
        '/health' => {
          'get' => {
            '200' => {
              'text/plain' => 1
            }
          }
        }
      }
    end

    it 'merges the data correctly' do
      expect(subject.data.dig('/user', 'get', '200', 'application/json')).to eq(3)
      expect(subject.data.dig('/user', 'get', '400', 'text/html')).to eq(2)
    end
  end
end
