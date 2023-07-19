module OpenapiContracts::Validators
  class Base
    include OpenapiContracts::Helper

    class_attribute :final, instance_writer: false
    self.final = false

    def initialize(stack, env)
      @stack = stack # next matcher
      @env = env
      @errors = []
    end

    def call(errors = [])
      validate
      errors.push(*@errors)
      # Do not call the next matcher when there is errors on a final matcher
      return errors if @errors.any? && final?

      @stack.call(errors)
    end

    private

    delegate :operation, :options, :request, :response, to: :@env

    def response_desc
      "#{request.request_method} #{request.path}"
    end

    # :nocov:
    def validate
      raise NotImplementedError
    end
    # :nocov:
  end
end
