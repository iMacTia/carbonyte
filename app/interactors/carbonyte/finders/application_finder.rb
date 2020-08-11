# frozen_string_literal: true

module Carbonyte
  # Carbonyte module for Finders.
  # Finders are Interactors whose main task is to build a query
  module Finders
    # Carbonyte base class for all finders interactors.
    # Finders are used to build queries based on parameters
    class ApplicationFinder < ApplicationInteractor
      # Default limit for pagination
      DEFAULT_LIMIT = 25

      # Starts building the query (:scope)
      #
      # @option context:params [Hash] the parameters used to build the query scope
      # @option context:params:include [String] a comma-separated list of relations to include
      # @option context:params:sort [String] a comma-separated list of columns to use to sort.
      #   If the "-" prefix is provided then the sort will be descending, ascending otherwise
      # @option context:params:limit [Integer] the number of items per page.
      #   Defaults to +DEFAULT_LIMIT+
      # @option context:params:page [Integer] the page to load. Defaults to 1
      def call
        include_relations if context.params[:include].present?
        sort if context.params[:sort].present?
        paginate
      end

      protected

      # Returns true if the provided relation can be included
      # @param _rel [Symbol] the relation to include
      def can_include?(_rel)
        false
      end

      private

      def include_relations
        context.params[:include].split(',').each do |relation|
          next unless can_include?(relation)

          context.scope = context.scope.includes(relation)
        end
      end

      def sort_properties
        context.params[:sort].split(',')
      end

      def sort_exp(prop)
        return prop unless prop.start_with?('-')

        { prop[1..] => :desc }
      end

      def sort
        sort_properties.each do |prop|
          context.scope = context.scope.order(sort_exp(prop))
        end
      end

      def paginate
        context.scope = context.scope.limit(context.params[:limit] || DEFAULT_LIMIT)
        context.scope = context.scope.page(context.params[:page] || 1)
      end
    end
  end
end
