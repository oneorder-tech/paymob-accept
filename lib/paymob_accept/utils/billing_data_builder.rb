module PaymobAccept
  module Utils
    class BillingDataBuilder
      def build(customer:, address:)
        {
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
        }
      end
    end
  end

  class OrderDataBuilder
    def build(auth_token:, amount_cents:, amount_currency:)
      {
        "auth_token": auth_token,
        "delivery_needed": false,
        "amount_cents": amount_cents.to_i,
        "currency": amount_currency,
        "items": []
      }
    end
  end
end
