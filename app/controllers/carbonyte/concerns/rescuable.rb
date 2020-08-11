# frozen_string_literal: true

module Carbonyte
  # The Rescuable concern rescues controllers from bubbling up the most common exceptions
  # and provides a uniformed response body in case of such errors.
  # @see https://jsonapi.org/format/#error-objects
  module Rescuable
    extend ActiveSupport::Concern

    included do
      rescue_from Pundit::NotAuthorizedError, with: :unauthorized
      rescue_from Interactor::Failure, with: :interactor_failure
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    end

    private

    def serialized_errors(payload)
      payload = [payload] unless payload.is_a?(Enumerable)
      payload.to_json
    end

    def unauthorized(exc)
      payload = {
        code: exc.class.name,
        source: { policy: exc.policy.class.name },
        title: 'Not Authorized By Policy',
        detail: exc.message
      }
      render json: serialized_errors(payload), status: :unauthorized
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
      record.messages.map do |field, errors|
        errors.map do |error_message|
          {
            code: code,
            source: { pointer: "attributes/#{field}" },
            title: 'Invalid Field ',
            detail: error_message
          }
        end
      end
    end
  end
end
