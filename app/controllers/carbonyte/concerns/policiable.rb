# frozen_string_literal: true

module Carbonyte
  module Concerns
    # The Policiable concern integrates with Pundit to manage policies
    module Policiable
      extend ActiveSupport::Concern

      included do
        include Pundit
        rescue_from Pundit::NotAuthorizedError, with: :policy_not_authorized
      end

      private

      def policy_not_authorized(exc)
        payload = {
          code: exc.class.name,
          source: { policy: exc.policy.class.name },
          title: 'Not Authorized By Policy',
          detail: exc.message
        }
        render json: serialized_errors(payload), status: :forbidden
      end
    end
  end
end
