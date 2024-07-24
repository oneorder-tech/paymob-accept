# frozen_string_literal: true

module PaymobAccept
  module Pay 
    module Egypt 
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

      # 3. Payment Key Request
      def generate_payment_intent(customer:, address:, integration_id:, amount_cents:, amount_currency:, cc_token: nil, iframe_id: nil, order_id: nil, auth_token: get_auth_token)
        if order_id.nil?
          order = create_order(amount_cents: amount_cents, amount_currency: amount_currency)
          order_id = order['id']
        end
        super(customer: customer, address: address, integration_id: integration_id,
              amount_cents: amount_cents, amount_currency: amount_currency,
               cc_token: cc_token, iframe_id: iframe_id, order_id: order_id, auth_token: auth_token) 
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
