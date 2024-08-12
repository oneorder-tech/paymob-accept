module PaymobAccept
  class PaymentProcessor
    SUPPORTED_PAYMENT_METHODS = %i[online auth kiosk cash wallet moto].freeze

    def process(method:, **kwargs)
      kwargs[:amount_currency] = kwargs[:amount_currency] || PaymobAccept.configuration.currency
      validate_payment_method!(method)
      validate_data!(customer: kwargs[:customer], address: kwargs[:address], currency: kwargs[:amount_currency])
      "PaymobAccept::PaymentMethods::#{method.to_s.classify}".constantize.new(**kwargs).charge
    end

    private

    def validator
      @validator ||= PaymobAccept::Pay::Validator.new
    end

    def validate_data!(customer:, address:, currency:)
      validator.validate!(customer: customer, address: address) && validate_currency!(currency)
    end

    def validate_currency!(currency)
      available_currencies = %w[AED EGP]
      return if available_currencies.include?(currency)

      raise ArgumentError,
            "Only #{available_currencies.join(', ')} are supported"
    end

    def validate_payment_method!(method)
      return if SUPPORTED_PAYMENT_METHODS.include?(method)

      raise ArgumentError,
            "unsupported payment method #{method}"
    end
  end
end
