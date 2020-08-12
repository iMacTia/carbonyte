# frozen_string_literal: true

module Carbonyte
  module Concerns
    # The Serializable concern helps with JSON:API serialization
    module Serializable
      extend ActiveSupport::Concern

      def serializer_options
        {
          include: include_option,
          params: {
            current_user: current_user
          }
        }
      end

      def include_option
        return [] unless params[:include]

        params[:include].split(',').map(&:to_sym)
      end
    end
  end
end
