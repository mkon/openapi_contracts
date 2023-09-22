RSpec.describe OpenapiContracts::Coverage::Store do
  subject { described_class.new }

  it 'stores coverage hits correctly' do
    subject.increment!('/health', 'get', '200', 'text/plain')
    subject.increment!('/user', 'get', '200', 'application/json')
    subject.increment!('/user', 'get', '200', 'application/json')
    subject.increment!('/user', 'get', '401', 'application/json')
    subject.increment!('/user', 'post', '400', 'application/json')
    subject.increment!('/user', 'post', '400', 'application/json')
    expect(subject.data).to eq(
      '/health' => {'get'=>{'200'=>{'text/plain'=>1}}},
      '/user'   => {
        'get'  => {
          '200' => {'application/json'=>2},
          '401' => {'application/json'=>1}
        },
        'post' => {'400'=>{'application/json'=>2}}
      }
    )
  end
end
