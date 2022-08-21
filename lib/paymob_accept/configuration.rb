module PaymobAccept
  class Configuration
    attr_accessor :api_key, :online_integration_id, :cash_integration_id, :kiosk_integration_id,
                  :auth_integration_id, :wallet_integration_id, :moto_integration_id
  end

  class ConfigurationMissingError < StandardError; end
end
