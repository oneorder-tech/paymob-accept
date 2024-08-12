module PaymobAccept
  module PaymentKeyGenerator
    class Base
      def generate(client:, integration_id:, amount_cents:, amount_currency:, order_id:, customer:, address:,
                   cc_token: nil)
        raise NotImplementedError, "#{self.class.name} must implement generate method"
      end

      protected

      def billing_data_builder
        @billing_data_builder ||= Utils::BillingDataBuilder.new
      end
    end
  end
end
