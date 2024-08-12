module PaymobAccept
  module PaymentMethods
    class Moto < Base
      def charge
        if cc_token.nil?
          raise ArgumentError,
                'You need to provide a credit card token for MOTO payments'
        end

        process do |payment_intent|
          body = {
            "source": { "subtype": 'TOKEN', "identifier": cc_token },
            "payment_token": payment_intent
          }
          @client.request('/api/acceptance/payments/pay', body, auth_headers)
        end
      end
    end
  end
end
