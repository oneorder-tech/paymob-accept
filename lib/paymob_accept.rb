# frozen_string_literal: true

require_relative 'paymob_accept/version'

require 'paymob_accept/configuration'
require 'paymob_accept/client'
require 'paymob_accept/payment_processor'
require 'paymob_accept/payment_methods/base'
require 'paymob_accept/payment_methods/online'
require 'paymob_accept/payment_methods/auth'
require 'paymob_accept/pay/payment_actions'
require 'paymob_accept/utils/billing_data_builder'
require 'paymob_accept/payment_key_generator/base'
require 'paymob_accept/payment_key_generator/eg_generator'
require 'paymob_accept/payment_key_generator/uae_generator'
require 'paymob_accept/pay/validator'
require 'paymob_accept/hmac'
require 'json'
require 'faraday'
require 'faraday/net_http'
require 'json-schema'
require 'paymob_accept/errors/bad_gateway'
module PaymobAccept
  class Error < StandardError; end

  class << self
    # I should validate integrations here
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def process_payment(method, **kwargs)
    PaymentProcessor.new.process(method, **kwargs)
  end
end
