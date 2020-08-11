# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all serializers
  class ApplicationSerializer
    include JSONAPI::Serializer

    # Initializes the serializer.
    # @param resource [Object] the resource(s) to serialize
    # @param options [Hash] the serializer options.
    # @see https://github.com/jsonapi-serializer/jsonapi-serializer/blob/master/README.md
    def initialize(resource, options = {})
      parse_options(resource, options)
      super
    end

    private

    # Adds additional options automatically based on the resource
    def parse_options(resource, options)
      resource_options = if resource.is_a?(Enumerable)
                           options_for_list(resource)
                         else
                           options_for_object(resource)
                         end
      options.merge!(resource_options)
    end

    # For collections, the :meta option will be added to support pagination
    def options_for_list(list)
      options = {}
      options[:meta] = { total: list.total_entries } if list.respond_to?(:total_entries)
      options
    end

    def options_for_object(_resource)
      {}
    end
  end
end
