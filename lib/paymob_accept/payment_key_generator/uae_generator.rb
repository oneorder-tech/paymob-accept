module PaymobAccept
  module PaymentKeyGenerator
    class UaeGenerator < Base
      def generate(client:, integration_id:, amount_cents:, amount_currency:, customer:, address:, order_id: nil,
                   cc_token: nil)
        body = {
          amount: amount_cents,
          currency: amount_currency,
          expiration: 36_000,
          special_reference: order_id,
          payment_methods: [integration_id],
          billing_data: billing_data_builder.build(customer: customer, address: address),
          items: []
        }
        body['token'] = cc_token if cc_token
        response = client.request('/v1/intention/', body, secret_key_headers)
        { token: response.dig('payment_keys', 0, 'key'), transaction_reference: order_id }
      end

      private

      def secret_key_headers
        { 'Authorization' => "Token #{PaymobAccept.configuration.secret_key}" }
      end
    end
  end
end
