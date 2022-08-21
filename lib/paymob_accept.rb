# frozen_string_literal: true

require_relative 'paymob_accept/version'

require 'paymob_accept/configuration'
require 'paymob_accept'
require 'paymob_accept/api/base'
require 'paymob_accept/api/pay'
require 'paymob_accept/api/client'
require 'paymob_accept/api/charge'

require 'json'
require 'faraday'
require 'faraday/net_http'
require 'paymob_accept/errors/bad_gateway'
require 'json-schema'
module PaymobAccept
  class Error < StandardError; end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
