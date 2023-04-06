module OpenapiContracts::Matchers
  class Base
    class_attribute :final, instance_writer: false
    self.final = false

    def initialize(stack, spec, response)
      @stack = stack # next matcher
      @spec = spec
      @response = response
      @errors = []
    end

    def call(errors)
      validate
      errors.push(*@errors)
      # Do not call the next matcher when there is errors on a final matcher
      @stack.call(errors) if @errors.empty? || !final?
    end

    private

    def validate
      raise NotImplementedError
    end
  end
end
