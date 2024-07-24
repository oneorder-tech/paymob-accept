module PaymobAccept
  module PaymentKeyGenerator
    class UaeGenerator < Base
      def generate(client:, integration_id:, amount_cents:, amount_currency:, customer:, address:, order_id: nil,
                   cc_token: nil)
        transaction_reference = create_order(client: client, amount_cents: amount_cents, amount_currency: amount_currency,
                                             order_id: order_id)
        body = {
          amount: amount_cents,
          currency: amount_currency,
          expiration: 36_000,
          order_id: transaction_reference,
          payment_methods: [integration_id],
          billing_data: billing_data_builder.build(customer: customer, address: address),
          items: []
        }
        body['token'] = cc_token if cc_token
        response = client.request('/v1/intention/', body, secret_key_headers)
        { token: response.dig('payment_keys', 0, 'key'), transaction_reference: transaction_reference }
      end

      private

      def create_order(client:, amount_cents:, amount_currency:, order_id: nil)
        body = PaymobAccept::OrderDataBuilder.new.build(auth_token: client.authorize, amount_cents: amount_cents,
                                                        amount_currency: amount_currency)
        body['merchant_order_id'] = order_id if order_id
        response = client.request('/api/ecommerce/orders', body)
        response['id']
      end

      def secret_key_headers
        { 'Authorization' => "Token #{PaymobAccept.configuration.secret_key}" }
      end
    end
  end
end
