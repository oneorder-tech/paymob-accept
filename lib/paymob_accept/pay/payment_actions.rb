module PaymobAccept
  module Pay
    class PaymentActions
      attr_reader :transaction_id

      def initialize
        @client = PaymobAccept::Client.new
      end

      def inquire(transaction_id:)
        response = @client.get(endpoint: "/api/acceptance/transactions/#{transaction_id}", headers: auth_headers)
        JSON.parse(response.body).to_h
      end

      def capture!(transaction_id:, amount_cents:)
        body = {
          auth_token: @client.authorize,
          transaction_id: transaction_id,
          amount_cents: amount_cents
        }
        @client.request('/api/acceptance/capture', body, auth_headers)
      end

      def void!(transaction_id:)
        body = { transaction_id: transaction_id }
        response = @client.request('/api/acceptance/void_refund/void', body)
        ['true', true].include? response['success']
      end

      def refund!(transaction_id:, amount_cents:)
        body = { transaction_id: transaction_id, amount_cents: amount_cents }
        response = @client.request('/api/acceptance/void_refund/refund', body)
        ['true', true].include? response['success']
      end

      def auth_headers
        { 'Authorization' => "Bearer #{@client.authorize}" }
      end

      def inquire_with_order_id(order_id:)
        body = { auth_token: @client.authorize, order_id: order_id }
        begin
          @client.request('/api/ecommerce/orders/transaction_inquiry', body, auth_headers)
        rescue PaymobAccept::Errors::BadGateway => _e
          @retries ||= 0
          @retries += 1
          retry if @retries < 5
        end
      end
    end
  end
end
