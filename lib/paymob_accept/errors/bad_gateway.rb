module PaymobAccept
  module Errors
    class BadGateway < StandardError
      def initialize(message:)
        super(
          title: 'Bad Gateway',
          status: 502,
          detail: message || 'An error has occured communicating with the external gateway',
        )
      end
    end
  end
end
