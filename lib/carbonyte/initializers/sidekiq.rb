# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/logstash'

module Carbonyte
  module Initializers
    # This initializer setups sidekiq
    module Sidekiq
      extend ActiveSupport::Concern

      # Log type, this allows to distinguish these logs from others
      LOG_TYPE = 'WORKER'

      included do
        initializer 'carbonyte.sidekiq' do
          ::Sidekiq::Logstash.setup
          ::Sidekiq::Logstash.configure do |config|
            config.custom_options = lambda do |payload|
              payload['type'] = LOG_TYPE
            end
          end

          ::Sidekiq.configure_client do |config|
            # config.redis = { url: Rails.application.config.redis_url }
            config.client_middleware do |chain|
              chain.add Middleware::SaveRequestStore
            end
          end

          ::Sidekiq.configure_server do |config|
            # config.redis = { url: Rails.application.config.redis_url }
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
          # Overrides the standard Sidekiq middleware `call` method
          # @param job [Hash] an hash representing the job being executed
          def call(_worker, job, _queue, _redis_pool)
            job['current_user_id'] = RequestStore.store[:current_user_id]
            job['correlation_id'] = RequestStore.store[:correlation_id]
            yield
          end
        end

        # This Server middleware retrieves the RequestStore payload from the job and ensures
        # it gets cleared before the next job execution
        class LoadRequestStore
          # Overrides the standard Sidekiq middleware `call` method
          # @param job [Hash] an hash representing the job being executed
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
