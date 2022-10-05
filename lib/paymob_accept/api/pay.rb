# frozen_string_literal: true

module PaymobAccept
  module Api
    class Pay < Base
      SUPPORTED_PAYMENT_METHODS = %i[online auth kiosk cash wallet moto].freeze

      attr_accessor :api_key, :online_integration_id, :cash_integration_id, :kiosk_integration_id,
                    :auth_integration_id, :wallet_integration_id, :moto_integration_id

      def initialize(api_key: PaymobAccept.configuration.api_key, online_integration_id: PaymobAccept.configuration.online_integration_id, cash_integration_id: PaymobAccept.configuration.cash_integration_id, kiosk_integration_id: PaymobAccept.configuration.kiosk_integration_id,
                     auth_integration_id: PaymobAccept.configuration.auth_integration_id, wallet_integration_id: PaymobAccept.configuration.wallet_integration_id, moto_integration_id: PaymobAccept.configuration.moto_integration_id)
        super(api_key: api_key)
        @api_key = api_key
        @online_integration_id = online_integration_id
        @cash_integration_id = cash_integration_id
        @kiosk_integration_id = kiosk_integration_id
        @auth_integration_id = auth_integration_id
        @wallet_integration_id = wallet_integration_id
        @moto_integration_id = moto_integration_id
      end

      def charge(method:, **kwargs)
        raise ArgumentError, "unsupported payment method #{method}" unless SUPPORTED_PAYMENT_METHODS.include? method

        # Override any currencies, only EGP is currently supported
        kwargs[:amount_currency] = 'EGP'
        send("pay_#{method}".to_sym, **kwargs)
      end

      private

      def pay_auth(customer:, address:, amount_cents:, amount_currency:)
        generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                integration_id: auth_integration_id)
      end

      # Return an iFrame URL if an iframe_id is provided. Otherwise, returns a payment token
      # The iFrame will be prepoulated with the credit card info if cc_token is present and is valid stored credit card token on Paymob's server
      def pay_online(customer:, address:, amount_cents:, amount_currency:, cc_token: nil, iframe_id: nil)
        generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                integration_id: online_integration_id, iframe_id: iframe_id, cc_token: cc_token)
      end

      # Paying MOTO (ie. with a saved card token)
      def pay_moto(customer:, address:, cc_token:, amount_cents:, amount_currency:)
        if cc_token.nil?
          raise ArgumentError,
                'You need to provide a credit card token for MOTO payments'
        end

        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                                 integration_id: auth_integration_id)
        body = {
          "source": { "subtype": 'TOKEN', "identifier": cc_token },
          "payment_token": bill_reference
        }
        @client.request('/acceptance/payments/pay', body)
      end

      def pay_wallet(customer:, address:, amount_cents:, amount_currency:)
        wallet_phone_number = customer[:wallet_phone_number] || customer[:phone_number]

        if wallet_phone_number.nil?
          raise ArgumentError,
                'You need to provide a mobile number for wallet payments'
        end

        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                                 integration_id: wallet_integration_id)
        body = {
          "source": { "subtype": 'WALLET', "identifier": wallet_phone_number },
          "payment_token": bill_reference
        }
        @client.request('/acceptance/payments/pay', body)
      end

      def pay_cash(customer:, address:, amount_cents:, amount_currency:)
        if address.nil?
          raise ArgumentError,
                "Please provide a valid address in options. You must provide those keys: #{address_schema[:required]}"
        end

        address_validator(address)

        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents,
                                                 amount_currency: amount_currency, integration_id: cash_integration_id)
        body = {
          "source": { "subtype": 'CASH', "identifier": 'cash' },
          "payment_token": bill_reference
        }
        @client.request('/acceptance/payments/pay', body)
      end

      def pay_kiosk(customer:, address:, amount_cents:, amount_currency:)
        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents,
                                                 amount_currency: amount_currency, integration_id: kiosk_integration_id)
        body = {
          "source": { "subtype": 'AGGREGATOR', "identifier": 'aggregator' },
          "payment_token": bill_reference
        }

        @client.request('/acceptance/payments/pay', body)
      end
    end
  end
end
