# frozen_string_literal: true

require 'lograge'

module Carbonyte
  module Initializers
    # This initializer setups lograge and automatically logs exceptions
    module Lograge
      extend ActiveSupport::Concern

      included do
        initializer 'carbonyte.lograge' do
          Rails.application.configure do
            config.lograge.enabled = true
            config.lograge.base_controller_class = 'ActionController::API'
            config.lograge.formatter = ::Lograge::Formatters::Logstash.new

            config.lograge.custom_options = lambda do |event|
              Carbonyte::Initializers::Lograge.custom_options(event)
            end

            config.lograge.custom_payload do |controller|
              Carbonyte::Initializers::Lograge.custom_payload(controller)
            end
          end
        end
      end

      class << self
        def custom_options(_event)
          opts = {
            correlation_id: RequestStore.store[:correlation_id],
            environment: Rails.env,
            pid: ::Process.pid
          }
          add_rescued_exception(opts, RequestStore.store[:rescued_exception])
          opts
        end

        def add_rescued_exception(opts, exc)
          return unless exc

          opts[:rescued_exception] = {
            name: exc.class.name,
            message: exc.message,
            backtrace: %('#{Array(exc.backtrace).join("\n\t")}')
          }
        end

        def custom_payload(controller)
          exceptions = %w[controller action]
          {
            params: controller.params.except(*exceptions).to_s,
            headers: parse_headers(controller.request.headers),
            user_id: controller.current_user&.id,
            remote_ip: controller.remote_ip
          }
        end

        def parse_headers(headers)
          headers.to_h.select { |k, _v| k.start_with?('HTTP') and k != 'HTTP_COOKIE' }
        end
      end
    end
  end
end
