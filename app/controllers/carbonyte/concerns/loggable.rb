# frozen_string_literal: true

module Carbonyte
  module Concerns
    # The Loggable concern integrates with lograge to log efficiently
    module Loggable
      extend ActiveSupport::Concern

      # Used for logging IP.
      # @see Carbonyte::Engine
      def remote_ip
        request.headers['HTTP_X_FORWARDED_FOR'] || request.headers['HTTP_X_REAL_IP'] || request.remote_ip
      end
    end
  end
end
