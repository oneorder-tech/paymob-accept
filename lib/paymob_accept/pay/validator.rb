module PaymobAccept
  module Pay
    class Validator 
      COUNTRY = PaymobAccept.configuration.country.downcase
      CUSTOMER_SCHEMA = Rails.root.join("config/schemas/#{COUNTRY}/customer.json")
      ADDRESS_SCHEMA = Rails.root.join("config/schemas/#{COUNTRY}/address.json")

      def validate!(customer:, address:)
        customer_validator(customer)
        address_validator(address)
      end

      private 

      def customer_validator(customer)
        JSON::Validator.validate!(CUSTOMER_SCHEMA, customer)
      rescue JSON::Schema::ValidationError => e
        raise ArgumentError, "Customer hash has the following error: #{e.message}"
      end

      def address_validator(address)
        JSON::Validator.validate!(ADDRESS_SCHEMA, address)
      rescue JSON::Schema::ValidationError => e
        raise ArgumentError, "Address hash has the following error: #{e.message}"
      end
    end
  end
end