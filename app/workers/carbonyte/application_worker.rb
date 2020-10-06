# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all serializers
  class ApplicationWorker
    include Sidekiq::Worker

    # Retrieves the request correlation ID
    def correlation_id
      RequestStore.store[:correlation_id]
    end

    # Retrieves the current user ID
    def current_user_id
      RequestStore.store[:current_user_id]
    end
  end
end
