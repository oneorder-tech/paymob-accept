module PaymobAccept
  module Pay
    class Validator
      attr_reader :country, :customer_schema_path, :address_schema_path

      # Either move the schemas to backend files or add the schemas to this file
      def initialize
        @country = PaymobAccept.configuration.country.downcase
        @customer_schema_path = "#{Gem.loaded_specs['paymob_accept'].gem_dir}/lib/paymob_accept/schemas/#{country}/customer.json"
        @address_schema_path =  "#{Gem.loaded_specs['paymob_accept'].gem_dir}/lib/paymob_accept/schemas/#{country}/address.json"
      end

      def validate!(customer:, address:)
        customer_validator(customer)
        address_validator(address)
      end

      private

      def customer_validator(customer)
        customer_schema = load_schema(@customer_schema_path)
        JSON::Validator.validate!(customer_schema, customer)
      rescue JSON::Schema::ValidationError => e
        raise ArgumentError, "Customer hash has the following error: #{e.message}"
      end

      def address_validator(address)
        address_schema = load_schema(@address_schema_path)
        JSON::Validator.validate!(address_schema, address)
      rescue JSON::Schema::ValidationError => e
        raise ArgumentError, "Address hash has the following error: #{e.message}"
      end

      def load_schema(path)
        JSON.parse(File.read(path))
      rescue Errno::ENOENT
        raise ArgumentError, "Schema file not found at path: #{path}"
      rescue JSON::ParserError => e
        raise ArgumentError, "Invalid JSON schema: #{e.message}"
      end
    end
  end
end
