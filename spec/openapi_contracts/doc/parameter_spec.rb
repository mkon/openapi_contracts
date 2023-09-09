RSpec.describe OpenapiContracts::Doc::Parameter do
  subject(:parameter) { described_class.new(spec) }

  let(:spec) { OpenapiContracts::Doc::Schema.new(raw).navigate('components', 'parameters', 'Example') }
  let(:raw) do
    {
      'openapi'    => '3.0.0',
      'components' => {
        'parameters' => {
          'Example' => {
            'name'   => 'example',
            'schema' => schema
          }
        }
      }
    }
  end

  shared_examples 'a path parameter' do |expectations|
    expectations.each do |k, v|
      context "when the value is #{k.inspect}" do
        let(:value) { k }

        it { is_expected.to be v }
      end
    end
  end

  describe '#matches?(value)' do
    subject { parameter.matches?(value) }

    context 'when the param is a string with pattern' do
      let(:schema) do
        {
          'type'    => 'string',
          'pattern' => '^[a-f,0-9]{8}$'
        }
      end

      include_examples 'a path parameter', {
        '1234abcd' => true,
        '123'      => false
      }
    end

    context 'when the param is a string with length' do
      let(:schema) do
        {
          'type'      => 'string',
          'minLength' => 4,
          'maxLength' => 8
        }
      end

      include_examples 'a path parameter', {
        '1234'      => true,
        '12'        => false,
        '123456789' => false
      }
    end

    context 'when the param is an integer' do
      let(:schema) do
        {
          'type' => 'integer'
        }
      end

      include_examples 'a path parameter', {
        '1234'   => true,
        '1.234'  => false,
        'word'   => false,
        '-1234'  => true,
        '-1.234' => false
      }
    end

    context 'when the param is an integer with minimum -2' do
      let(:schema) do
        {
          'type'    => 'integer',
          'minimum' => -2
        }
      end

      include_examples 'a path parameter', {
        '1234'  => true,
        '-2'    => true,
        '-1234' => false
      }
    end

    context 'when the param is an integer with exclusive minimum -2' do
      let(:schema) do
        {
          'type'             => 'integer',
          'minimum'          => -2,
          'exclusiveMinimum' => true
        }
      end

      include_examples 'a path parameter', {
        '0'  => true,
        '-2' => false
      }

      context 'when using openapi 3.1' do
        let(:schema) do
          {
            'type'             => 'integer',
            'exclusiveMinimum' => -2
          }
        end

        before do
          raw['openapi'] = '3.1'
        end

        include_examples 'a path parameter', {
          '0'  => true,
          '-2' => false
        }
      end
    end

    context 'when the param is an integer with maximum 2' do
      let(:schema) do
        {
          'type'    => 'integer',
          'maximum' => 2
        }
      end

      include_examples 'a path parameter', {
        '1234'  => false,
        '2'     => true,
        '-2'    => true,
        '-1234' => true
      }
    end

    context 'when the param is an integer with exclusive maximum 2' do
      let(:schema) do
        {
          'type'             => 'integer',
          'maximum'          => 2,
          'exclusiveMaximum' => true
        }
      end

      include_examples 'a path parameter', {
        '2' => false,
        '0' => true
      }
    end

    context 'when the param is an integer with minimum 0 and maximum 1234' do
      let(:schema) do
        {
          'type'    => 'integer',
          'minimum' => 0,
          'maximum' => 1234
        }
      end

      include_examples 'a path parameter', {
        '1234'  => true,
        '2'     => true,
        '-2'    => false,
        '-1234' => false
      }
    end

    context 'when the param is a number' do
      let(:schema) do
        {
          'type' => 'number'
        }
      end

      include_examples 'a path parameter', {
        '1234'   => true,
        '1.234'  => true,
        'word'   => false,
        '-1234'  => true,
        '-1.234' => true
      }
    end

    context 'when the param is a number with minimum -2' do
      let(:schema) do
        {
          'type'    => 'number',
          'minimum' => -2
        }
      end

      include_examples 'a path parameter', {
        '1234'   => true,
        '1.234'  => true,
        'word'   => false,
        '-1234'  => false,
        '-1.234' => true
      }
    end

    context 'when the param is a number with maximum 2' do
      let(:schema) do
        {
          'type'    => 'number',
          'maximum' => 2
        }
      end

      include_examples 'a path parameter', {
        '1234'   => false,
        '1.234'  => true,
        'word'   => false,
        '-1234'  => true,
        '-1.234' => true
      }
    end

    context 'when the param is a number with minimum 0 and maximum 1000' do
      let(:schema) do
        {
          'type'             => 'number',
          'minimum'          => 0,
          'maximum'          => 1000,
          'exclusiveMaximum' => true
        }
      end

      include_examples 'a path parameter', {
        '1234'   => false,
        '1.234'  => true,
        'word'   => false,
        '-1234'  => false,
        '-1.234' => false
      }
    end

    context 'when the param is an array' do
      let(:schema) do
        {
          'type' => 'array'
        }
      end

      # Array is not yet supported and will not match
      include_examples 'a path parameter', {
        '1,2,3' => false
      }
    end
  end
end
