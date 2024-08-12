module PaymobAccept
  class Client
    attr_reader :api_endpoint

    def initialize
      @api_endpoint = PaymobAccept.configuration.base_url
    end

    def authorize
      response = Faraday.post(
        "#{@api_endpoint}/api/auth/tokens",
        { api_key: PaymobAccept.configuration.api_key }.to_json,
        'Content-Type' => 'application/json'
      )
      raise StandardError, "code: #{response.status}, response: #{response.body}" unless response.success?

      JSON.parse(response.body).dig('token')
    end

    def get(endpoint:, params: {}, headers: {})
      response = Faraday.get(
        "#{@api_endpoint}/#{endpoint}",
        params,
        headers
      )
      raise StandardError, "code: #{response.status}, response: #{response.body}" unless response.success?

      response
    end

    def request(endpoint, body = {}, headers = {})
      puts '================'
      puts endpoint
      puts '================'
      headers.merge!('Content-Type' => 'application/json')
      response = Faraday.post(
        "#{@api_endpoint}/#{endpoint.gsub(%r{^/+}, '')}",
        body.to_json,
        headers
      )

      begin
        parsed_body = JSON.parse(response.body).to_h
      rescue StandardError => e
        # Manually send the error to Sentry
      end
      puts '================'
      puts parsed_body
      puts '================'

      unless response.success?
        message = parsed_body&.dig('message') || response.body || default_error_message
        raise PaymobAccept::Errors::BadGateway.new(message: "code: #{response.status}, gateway response: #{message}")
      end

      handle_paymob_request_errors unless paymob_request_successful?(parsed_body)

      parsed_body
    end

    def handle_paymob_request_errors
      raise PaymobAccept::Errors::BadGateway.new(message: default_error_message)
    end

    def default_error_message
      'Gateway could not handle your request properly. Please try again later.'
    end

    def paymob_request_successful?(response)
      !response.key?('success') || (response.key?('success') && ([true,
                                                                  'true'].include?(response['success']) || ([false,
                                                                                                             'false'].include?(response['success']) && [
                                                                                                               true, 'true'
                                                                                                             ].include?(response['pending']))))
    end
  end
end
