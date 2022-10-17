module PaymobAccept
  module Hmac
    FILTERED_TRANSACTION_KEYS = %w[amount_cents created_at currency error_occured has_parent_transaction id
                       integration_id is_3d_secure is_auth is_capture is_refunded is_standalone_payment
                       is_voided order.id owner
                       pending source_data.pan source_data.sub_type source_data.type success].freeze

    FILTERED_TOKEN_KEYS = %w[card_subtype created_at email id masked_pan merchant_id order_id token].freeze

    class << self

      def validate(paymob_response:, hmac_key: PaymobAccept.configuration.hmac_key)
        validate_transaction?(paymob_response: paymob_response, hmac_key: hmac_key) || validate_token?(paymob_response: paymob_response, hmac_key: hmac_key)
      end

      def validate_transaction?(paymob_response:, hmac_key: PaymobAccept.configuration.hmac_key)
        digest = OpenSSL::Digest.new('sha512')
        concatenated_str = FILTERED_TRANSACTION_KEYS.map do |element|
          paymob_response.dig('obj', *element.split('.'))
        end.join
        secure_hash = OpenSSL::HMAC.hexdigest(digest, hmac_key, concatenated_str)
        secure_hash == paymob_response['hmac']
      end

      def validate_token?(paymob_response:, hmac_key: PaymobAccept.configuration.hmac_key)
        digest = OpenSSL::Digest.new('sha512')
        concatenated_str = FILTERED_TOKEN_KEYS.map do |element|
          paymob_response.dig('obj', *element.split('.'))
        end.join
        secure_hash = OpenSSL::HMAC.hexdigest(digest, hmac_key, concatenated_str)
        secure_hash == paymob_response['hmac']
      end
    end
  end
end
