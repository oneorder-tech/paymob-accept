module PaymobAccept
  module PaymentMethods
    class Wallet < Base
      def charge
        process do |payment_intent|
          body = {
            "source": { "subtype": 'WALLET', "identifier": wallet_phone_number },
            "payment_token": payment_intent
          }
          @client.request('/api/acceptance/payments/pay', body, auth_headers)
        end
      end
    end
  end
end
