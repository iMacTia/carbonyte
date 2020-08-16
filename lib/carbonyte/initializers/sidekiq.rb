# frozen_string_literal: true

require 'lograge'

module Carbonyte
  module Initializers
    # This initializer setups sidekiq
    module Sidekiq
      extend ActiveSupport::Concern

      included do
        initializer 'carbonyte.sidekiq' do
          Sidekiq::Logstash.setup

          ::Sidekiq.configure_client do |config|
            config.redis = { url: Rails.application.config.redis_url }
            config.client_middleware do |chain|
              chain.add Middleware::SaveRequestStore
            end
          end

          ::Sidekiq.configure_server do |config|
            config.redis = { url: Rails.application.config.redis_url }
            config.server_middleware do |chain|
              chain.add Middleware::LoadRequestStore
            end
          end
        end
      end

      # This module contains Client and Server middleware
      module Middleware
        # This Client middleware adds the RequestStore payload to the job
        class SaveRequestStore
          def call(_worker, job, _queue)
            job['current_user_id'] = RequestStore.store[:current_user_id]
            job['correlation_id'] = RequestStore.store[:correlation_id]
            yield
          end
        end

        # This Server middleware retrieves the RequestStore payload from the job and ensures
        # it gets cleared before the next job execution
        class LoadRequestStore
          def call(_worker, job, _queue)
            RequestStore.store[:current_user_id] = job['current_user_id']
            RequestStore.store[:correlation_id] = job['correlation_id']
            yield
          ensure
            ::RequestStore.clear!
          end
        end
      end
    end
  end
end
