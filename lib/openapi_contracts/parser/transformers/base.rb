module OpenapiContracts::Parser::Transformers
  class Base
    def initialize(parser, cwd, pointer)
      @parser = parser
      @cwd = cwd
      @pointer = pointer
    end

    # :nocov:
    def call
      raise NotImplementedError
    end
    # :nocov:
  end
end
