# frozen_string_literal: true

require 'request_store'

module Carbonyte
  # Module enclosing all concerns
  module Concerns
    # The Correlatable concern automatically manages the correlation ID
    module Correlatable
      extend ActiveSupport::Concern

      included do
        before_action :find_or_create_correlation_id
        after_action :send_correlation_id
      end

      # Retrieves the request correlation ID
      def correlation_id
        RequestStore.store[:correlation_id]
      end

      protected

      # Finds the correlation ID in the request.
      # Can be overridden to fit the application
      def find_correlation_id
        request.headers['X-Correlation-Id'] || request.headers['X-Request-Id']
      end

      # Generates a correlation ID (defaults to Rails auto-generated one).
      # Can be overridden to fit the application
      def create_correlation_id
        request.request_id || SecureRandom.uuid
      end

      private

      def find_or_create_correlation_id
        correlation_id = find_correlation_id || create_correlation_id
        RequestStore.store[:correlation_id] = correlation_id
      end

      def send_correlation_id
        response.set_header('X-Correlation-Id', correlation_id)
      end
    end
  end
end
