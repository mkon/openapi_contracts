RSpec::Matchers.define :match_openapi_doc do |doc, options = {}| # rubocop:disable Metrics/BlockLength
  include OpenapiContracts::Helper

  match do |response|
    match = OpenapiContracts::Match.new(
      doc,
      response,
      options.merge({status: @status}.compact)
    )
    return true if match.valid?

    @errors = match.errors
    false
  end

  description do
    desc = 'match the openapi schema'
    desc << " with #{http_status_desc(@status)}" if @status
    desc
  end

  # :nocov:
  failure_message do |_response|
    @errors.map { |e| "* #{e}" }.join("\n")
  end
  # :nocov:

  def with_http_status(status)
    if status.is_a? Symbol
      @status = Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
    else
      @status = status
    end
    self
  end
end
