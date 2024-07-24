module PaymobAccept
  module PaymentMethods
    class Auth < Base
      def charge
        process { |payment_intent| { token: format_bill_reference(payment_intent), order_id: transaction_reference } }
      end
    end
  end
end
