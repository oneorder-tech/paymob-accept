# require 'erb'
# require 'yaml'

module PaymobAccept
  class Configuration
    attr_accessor :api_key

  end

  class ConfigurationMissingError < StandardError; end
end
