# frozen_string_literal: true

module PaymobAccept
  module Pay 
    module Uae
      class  Pay< ::Base

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

        private


        def pay_auth(customer:, address:, amount_cents:, amount_currency:, iframe_id: nil, cc_token: nil)
          generate_payment_intent(customer: customer, address: address, amount_cents: amount_cents, amount_currency: amount_currency,
                                  integration_id: auth_integration_id, iframe_id: iframe_id, cc_token: cc_token)
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




      def create_order(amount_cents:, amount_currency:  PaymobAccept.configuration.currency, auth_token: get_auth_token,
                       delivery_needed: false, items: [])
        body = {
          "auth_token": auth_token,
          "delivery_needed": delivery_needed,
          "amount_cents": amount_cents.to_i,
          "currency": amount_currency,
          "items": items
        }
        @client.request('/ecommerce/orders', body)
      end

      private

      def generate_payment_key(customer:, address:, amount_cents:, amount_currency:, integration_id:, cc_token: nil, order_id: nil, auth_token: get_auth_token)
        puts '================'
        puts integration_id
        puts '================'
        
        body = {
          "auth_token": auth_token,
          "amount": amount_cents.to_i,
          "currency": amount_currency,
          "expiration": 36_000,
          "order_id": order_id, # Remote
          "integrations": integration_id,
          "payment_methods": [integration_id],
          "billing_data": {
            "first_name": customer&.dig(:first_name) || customer&.dig(:name)&.split(/\s/, 2)&.first,
            "last_name": customer&.dig(:last_name) || customer&.dig(:name)&.split(/\s/, 2)&.last,
            "email": customer[:email],
            "phone_number": customer&.dig(:phone_number),
            "street": address&.dig(:address_line1) || 'NA',
            "building": address&.dig(:address_line2) || 'NA',
            "floor": address&.dig(:address_clarification) || 'NA',
            "apartment": 'NA',
            "postal_code": address&.dig(:postal_code) || 'NA',
            "city": address&.dig(:region) || 'NA',
            "state": address&.dig(:city) || 'NA',
            "country": address&.dig(:country) || 'NA',
            "shipping_method": 'PKG'
          },
          items: [],
         
        }
        body['token'] = cc_token unless cc_token.nil?

        response = @client.request('/v1/intention/', body)

        response['token']
      end

      def format_bill_reference(payment_token, iframe_id)
        iframe_id.nil? ? payment_token : "#{Api::Client::API_ENDPOINT}/acceptance/iframes/#{iframe_id}?payment_token=#{payment_token}"
      end
      end
    end
  end
end
