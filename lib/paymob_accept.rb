# frozen_string_literal: true

require_relative 'paymob_accept/version'

require 'paymob_accept/configuration'
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
  # Your code goes here...
end
