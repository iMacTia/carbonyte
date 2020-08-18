# frozen_string_literal: true

module Carbonyte
  module Concerns
    # The Rescuable concern rescues controllers from bubbling up the most common exceptions
    # and provides a uniformed response body in case of such errors.
    # @see https://jsonapi.org/format/#error-objects
    module Rescuable
      extend ActiveSupport::Concern

      included do
        rescue_from Pundit::NotAuthorizedError, with: :unauthorized
        rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
        rescue_from Interactor::Failure, with: :interactor_failure
        rescue_from ActiveRecord::RecordInvalid,
                    ActiveRecord::RecordNotSaved,
                    with: :record_invalid
        # Last one is for any other error
        rescue_from StandardError, with: :internal_error
      end

      # Upon rescuing an exception, stores that exception in RequestStore for later logging
      # @param exception [StandardError] the rescued exception
      def rescue_with_handler(exception)
        RequestStore.store[:rescued_exception] = exception
        super
      end

      # This is a special case
      def route_not_found
        payload = {
          code: 'RoutingError',
          source: request.path,
          title: 'Route not found',
          detail: "No route matches #{request.path}"
        }
        render json: serialized_errors(payload), status: :not_found
      end

      private

      def serialized_errors(payload)
        payload = [payload] unless payload.is_a?(Enumerable)
        { errors: payload }.to_json
      end

      def unauthorized(exc)
        payload = {
          code: exc.class.name,
          source: { policy: exc.policy.class.name },
          title: 'Not Authorized By Policy',
          detail: exc.message
        }
        render json: serialized_errors(payload), status: :forbidden
      end

      def record_not_found(exc)
        payload = {
          code: exc.class.name,
          source: {
            model: exc.model,
            id: exc.id
          },
          title: 'Resource Not Found',
          detail: exc.message
        }
        render json: serialized_errors(payload), status: :not_found
      end

      def interactor_failure(exc)
        payload = {
          code: exc.class.name,
          source: { interactor: exc.context._called.last.class.name },
          title: 'Interactor Failure',
          detail: exc.context.error
        }
        render json: serialized_errors(payload), status: :unprocessable_entity
      end

      def record_invalid(exc)
        payload = errors_for_record(exc.record, exc.class.name).flatten
        render json: serialized_errors(payload), status: :unprocessable_entity
      end

      def errors_for_record(record, code)
        record.errors.messages.map do |field, errors|
          errors.map do |error_message|
            {
              code: code,
              source: { pointer: "attributes/#{field}" },
              title: 'Invalid Field',
              detail: error_message
            }
          end
        end
      end

      def internal_error(exc)
        payload = {
          code: exc.class.name,
          title: 'Internal Server Error',
          detail: exc.message
        }
        render json: serialized_errors(payload), status: :internal_server_error
      end
    end
  end
end
