module PaymobAccept
  module Hmac
    FILTERED_KEYS = %w[amount_cents created_at currency error_occured has_parent_transaction id
                       integration_id is_3d_secure is_auth is_capture is_refunded is_standalone_payment
                       is_voided order.id owner
                       pending source_data.pan source_data.sub_type source_data.type success].freeze

    class << self
      def validate(paymob_response)
        if PaymobAccept.configuration.hmac_key.nil?
          raise ConfigurationMissingError,
                'Please, add hmac_key to your configuration block'
        end

        digest = OpenSSL::Digest.new('sha512')
        concatenated_str = FILTERED_KEYS.map do |element|
          paymob_response.dig('obj', *element.split('.'))
        end.join
        secure_hash = OpenSSL::HMAC.hexdigest(digest, PaymobAccept.configuration.hmac_key, concatenated_str)
        secure_hash == paymob_response['hmac']
      end
    end
  end
end
