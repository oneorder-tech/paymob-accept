module PaymobAccept
  module PaymentKeyGenerator
    class EgGenerator < Base
      def generate(client:, integration_id:, amount_cents:, amount_currency:, customer:, address:, order_id: nil,
                   cc_token: nil)
        transaction_reference = create_order(client: client, amount_cents: amount_cents, amount_currency: amount_currency,
                                             order_id: order_id)
        body = {
          auth_token: client.authorize,
          amount_cents: amount_cents.to_i,
          currency: amount_currency,
          expiration: 36_000,
          order_id: transaction_reference,
          integration_id: integration_id,
          billing_data: billing_data_builder.build(customer: customer, address: address)
        }
        body['token'] = cc_token if cc_token

        response = client.request('/api/acceptance/payment_keys', body, auth_headers(client))
        { token: response['token'], transaction_reference: transaction_reference }
      end

      private

      def create_order(client:, amount_cents:, amount_currency:, order_id: nil)
        body = PaymobAccept::OrderDataBuilder.new.build(auth_token: client.authorize, amount_cents: amount_cents,
                                                        amount_currency: amount_currency)
        body['merchant_order_id'] = order_id if order_id
        response = client.request('/api/ecommerce/orders', body)
        response['id']
      end

      def auth_headers(client)
        { 'Authorization' => "Bearer #{client.authorize}" }
      end
    end
  end
end
