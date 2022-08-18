# frozen_string_literal: true

module PaymobAccept
  module Api
    class Pay < Base
      def initialize(api_key: PaymobAccept.configuration.api_key)
        super(api_key: api_key)
      end

      def charge(customer:, address:, amount_cents:, integration_id:, method:, amount_currency: 'EGP', order_id: nil, iframe_id: nil, auth_token: get_auth_token)
        raise ArgumentError, "unsupported payment method #{method}" unless %i[online moto kiosk cash auth
                                                                              wallet].include? method

        send("pay_#{method}".to_sym,
             { auth_token: auth_token, customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
               integration_id: integration_id, iframe_id: iframe_id, order_id: order_id })
      end

      private

      def request_auth(customer:, address:, amount_cents:, amount_currency:, integration_id:, iframe_id:, order_id:, auth_token:)
        generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                integration_id: integration_id, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token)
      end

      # Returns iFrame URL. The iframe will be prepoulated if the credit card token is provided
      def pay_online(customer:, address:, amount_cents:, amount_currency:, integration_id:, iframe_id:, order_id:, auth_token:)
        generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                integration_id: integration_id, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token)
      end

      def pay_moto(customer:, address:, amount_cents:, amount_currency:, integration_id:, iframe_id:, order_id:, auth_token:)
        if customer[:cc_token].nil?
          raise ArgumentError,
                'You need to provide a credit card token for moto payments'
        end

        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                                 integration_id: integration_id, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token)
        body = {
          "source": { "subtype": 'TOKEN', "identifier": cc_token },
          "payment_token": bill_reference
        }
        @client.request('/acceptance/payments/pay', body)
      end

      def pay_wallet(customer:, address:, amount_cents:, amount_currency:, integration_id:, iframe_id:, order_id:, auth_token:)
        if customer[:wallet_mobile_number].nil?
          raise ArgumentError,
                'You need to provide a mobile number for wallet payments'
        end

        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                                 integration_id: integration_id, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token)
        body = {
          "source": { "subtype": 'WALLET', "identifier": wallet_mobile_number },
          "payment_token": bill_reference
        }
        @client.request('/acceptance/payments/pay', body)
      end

      def pay_cash(customer:, address:, amount_cents:, amount_currency:, integration_id:, iframe_id:, order_id:, auth_token:)
        if address.nil?
          raise ArgumentError,
                "Please provide a valid address in options. You must provide those keys: #{address_schema[:required]}"
        end

        address_validator(address)

        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                                 integration_id: integration_id, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token)
        body = {
          "source": { "subtype": 'CASH', "identifier": 'cash' },
          "payment_token": bill_reference
        }
        @client.request('/acceptance/payments/pay', body)
      end

      def pay_kiosk(customer:, address:, amount_cents:, amount_currency:, integration_id:, iframe_id:, order_id:, auth_token:)
        bill_reference = generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                                 integration_id: integration_id, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token)
        body = {
          "source": { "subtype": 'AGGREGATOR', "identifier": 'aggregator' },
          "payment_token": bill_reference
        }

        @client.request('/acceptance/payments/pay', body)
      end
    end
  end
end
