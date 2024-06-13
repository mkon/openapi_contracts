module OpenapiContracts::Validators
  # Validates the input parameters, eg path/url parameters
  class Parameters < Base
    include SchemaValidation

    private

    def validate
      operation.parameters.select(&:in_query?).each do |parameter|
        if request.GET.key?(parameter.name)
          value = request.GET[parameter.name]
          unless parameter.matches?(value)
            @errors << "#{value.inspect} is not a valid value for the query parameter #{parameter.name.inspect}"
          end
        elsif parameter.required?
          @errors << "Missing query parameter #{parameter.name.inspect}"
        end
      end
    end
  end
end
