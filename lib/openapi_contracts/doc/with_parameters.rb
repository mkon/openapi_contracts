module OpenapiContracts
  class Doc
    module WithParameters
      def parameters
        @parameters ||= Array.wrap(@spec.navigate('parameters')&.each&.map { |s| Doc::Parameter.new(s) })
      end
    end
  end
end
