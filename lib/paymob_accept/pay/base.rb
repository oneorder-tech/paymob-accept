module PaymobAccept
  module Pay
    class Base 
      SUPPORTED_PAYMENT_METHODS = %i[online auth kiosk cash wallet moto].freeze

      attr_accessor :client 

      def initialize
        @client = PaymobAccept::Client.new
      end

      def charge(method:, **kwargs)
        raise ArgumentError, "unsupported payment method #{method}" unless SUPPORTED_PAYMENT_METHODS.include?(method)

        kwargs[:amount_currency] =  kwargs[:amount_currency] || PaymobAccept.configuration.currency
        validate_data!(kwargs[:customer], kwargs[:address], kwargs[:amount_currency])

        send("pay_#{method}".to_sym, **kwargs)
      end

      def create_order 
        raise NotImplementedError, 'This is an abstract method'
      end

      def generate_payment_intention
        raise NotImplementedError, 'This is an abstract method'
      end

      def generate_payment_intent(**kwargs)

        payment_token = generate_payment_key(**kwargs)
      
        # EXTRACT FORMATTER DAH
        { token: format_bill_reference(payment_token, iframe_id), order_id: order_id }
      end

      private 

      def validator
        @validator ||= PaymobAccept::Pay::Validator.new
      end

      def validate_data!(customer: , address:, currency:)
        validator.validate!(customer, address) &&  validate_currency!(currency)      
      end

      def validate_currency!(currency)
        available_currencies = %w[AED EGP]
        raise ArgumentError, "Only #{available_currencies.join(', ')} are supported" unless available_currencies.include?(currency) 
      end
    end
  end
end