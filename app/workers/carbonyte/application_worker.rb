# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all serializers
  class ApplicationWorker
    include Sidekiq::Worker

    def correlation_id
      RequestStore.store[:correlation_id]
    end

    def current_user_id
      RequestStore.store[:current_user_id]
    end
  end
end
