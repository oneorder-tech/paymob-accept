module PaymobAccept
  module PaymentMethods
    class Cash < Base
      def charge
        process do |payment_intent|
          body = {
            "source": { "subtype": 'CASH', "identifier": 'cash' },
            "payment_token": payment_intent
          }
          @client.request('/api/acceptance/payments/pay', body, auth_headers)
        end
      end
    end
  end
end
