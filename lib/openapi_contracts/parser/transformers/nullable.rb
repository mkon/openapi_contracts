module OpenapiContracts::Parser::Transformers
  class Nullable < Base
    def call(object)
      return unless object['type'].present? && object['nullable'] == true

      object.delete('nullable')
      object['type'] = [object['type'], 'null']
    end
  end
end
