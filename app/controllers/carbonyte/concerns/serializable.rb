# frozen_string_literal: true

module Carbonyte
  module Concerns
    # The Serializable concern helps with JSON:API serialization
    module Serializable
      extend ActiveSupport::Concern

      # Helper method to render json responses
      # @param object [Any] the object (or list) to be serialized
      # @param serializer_class [JSONAPI::Serializer] serializer class to use. Inferred if not provided.
      # @param status [Symbol, Number] the status code to return, defaults to 200 (OK)
      # @example Serializes `user` using UserSerializer and returns status 200 (OK)
      #   user = User.find(123)
      #   serialize(user)
      # @example Serializes `created_record` using the specified UserSerializer and returning status 201 (CREATED)
      #   serialize(created_record, serializer: UserSerializer, status: :created)
      def serialize(object, serializer_class: nil, status: :ok)
        serializer_class ||= serializer_for(object)
        render json: serializer_class.new(object, serializer_options).serializable_hash.to_json, status: status
      end

      # Default options for serializers
      def serializer_options
        {
          include: include_option,
          params: {
            current_user: current_user
          }
        }
      end

      # Default include options for serializers
      def include_option
        return [] unless params[:include]

        params[:include].split(',').map(&:to_sym)
      end

      private

      def serializer_for(object)
        object = object.first if object.is_a?(Array)
        "#{object.class.name}Serializer".constantize
      end
    end
  end
end
