module PaymobAccept
  module PaymentMethods
    class Base
      attr_reader :client, :customer, :address, :amount_cents, :amount_currency, :order_id, :iframe_id, :cc_token, :transaction_reference

      def initialize(customer:, address:, amount_cents:, amount_currency:, iframe_id:, order_id: nil, cc_token: nil)
        @client = PaymobAccept::Client.new
        @customer = customer
        @address = address
        @amount_cents = amount_cents
        @amount_currency = amount_currency
        @iframe_id = iframe_id
        @order_id = order_id
        @cc_token = cc_token
      end

      def process
        payment_intent = generate_payment_intent(
          integration_id: PaymobAccept.configuration.send("#{self.class.name.demodulize.downcase}_integration_id"),
          cc_token: cc_token
        )
        yield(payment_intent)
      end

      private

      def generate_payment_intent(integration_id:, cc_token: nil)
        response = payment_intent_generator.generate(
          client: client,
          integration_id: integration_id,
          amount_cents: amount_cents,
          amount_currency: amount_currency,
          order_id: order_id,
          customer: customer,
          address: address,
          cc_token: cc_token,
        )
        @transaction_reference = response[:transaction_reference]
        response[:token]
      end

      def format_bill_reference(payment_intent)
        iframe_id.nil? ? payment_intent : "#{client.api_endpoint}/api/acceptance/iframes/#{iframe_id}?payment_token=#{payment_intent}"
      end

      def payment_intent_generator
        @payment_intent_generator ||= "PaymobAccept::PaymentKeyGenerator::#{PaymobAccept.configuration.country.capitalize}Generator".constantize.new
      end
    end
  end
end
