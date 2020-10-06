# frozen_string_literal: true

require 'lograge'

module Carbonyte
  module Initializers
    # This initializer setups lograge and automatically logs exceptions
    module Lograge
      extend ActiveSupport::Concern

      # Items to be removed from `params` hash
      PARAMS_EXCEPTIONS = %w[controller action].freeze
      # Log type, this allows to distinguish these logs from others
      LOG_TYPE = 'SERVER_REQUEST'

      included do
        initializer 'carbonyte.lograge' do
          Rails.application.config.tap do |config|
            config.lograge.enabled = true
            config.lograge.base_controller_class = 'ActionController::API'
            config.lograge.formatter = ::Lograge::Formatters::Logstash.new

            config.lograge.custom_options = lambda do |event|
              custom_options(event)
            end

            config.lograge.custom_payload do |controller|
              custom_payload(controller)
            end
          end
        end
      end

      # Adds custom options to the Lograge event
      def custom_options(event)
        opts = {
          type: LOG_TYPE,
          params: event.payload[:params].except(*PARAMS_EXCEPTIONS),
          correlation_id: RequestStore.store[:correlation_id],
          environment: Rails.env,
          pid: ::Process.pid
        }
        add_rescued_exception(opts, RequestStore.store[:rescued_exception])
        opts
      end

      # Adds the rescued exception (if any) to the Lograge event
      def add_rescued_exception(opts, exc)
        return unless exc

        opts[:rescued_exception] = {
          name: exc.class.name,
          message: exc.message,
          backtrace: %('#{Array(exc.backtrace.first(10)).join("\n\t")}')
        }
      end

      # Adds custom payload to the Lograge event
      def custom_payload(controller)
        payload = {
          headers: parse_headers(controller.request.headers),
          remote_ip: controller.remote_ip
        }
        payload[:user_id] = controller.current_user&.id if controller.respond_to?(:current_user)
        payload
      end

      # Parses headers returning only those starting with "HTTP", but excluding cookies
      def parse_headers(headers)
        headers.to_h.select { |k, _v| k.start_with?('HTTP') and k != 'HTTP_COOKIE' }
      end
    end
  end
end
