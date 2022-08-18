module PaymobAccept
  module Api
    class Charge < Base
      attr_reader :transaction_id

      def initialize(api_key: PaymobAccept.configuration.api_key)
        super(api_key: api_key)
      end

      def charge(transaction_id:)
        response = @client.get(endpoint: "/acceptance/transactions/#{transaction_id}", headers: auth_headers)
        JSON.parse(response.body).to_h
      end

      def capture!(transaction_id:, amount_cents:)
        body = {
          auth_token: get_auth_token,
          transaction_id: transaction_id,
          amount_cents: amount_cents
        }
        @client.request('/acceptance/capture', body)
      end

      def void!(transaction_id:)
        body = { auth_token: get_auth_token, transaction_id: transaction_id }
        response = @client.request('/acceptance/void_refund/void', body)
        ['true', true].include? response['success']
      end

      def refund!(transaction_id:, amount_cents:)
        body = { auth_token: get_auth_token, transaction_id: transaction_id, amount_cents: amount_cents }
        response = @client.request('/acceptance/void_refund/refund', body)
        ['true', true].include? response['success']
      end

      private

      def auth_headers
        { 'Authorization' => "Bearer #{get_auth_token}" }
      end
    end
  end
end
