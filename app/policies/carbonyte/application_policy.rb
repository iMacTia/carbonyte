# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all policies
  class ApplicationPolicy
    attr_reader :user, :record

    # Initializes a new policy with the current user and the record
    def initialize(user, record)
      @user = user
      @record = record
    end

    # Can the user get a list of records?
    def index?
      true
    end

    # Can the user get this specific record?
    def show?
      true
    end

    # Can the user create a new record?
    def create?
      true
    end

    # Can the user update this record?
    def update?
      true
    end

    # Can the user destroy this record?
    def destroy?
      true
    end

    # Carbonyte base class for all policy scopes
    class Scope
      attr_reader :user, :scope

      # Initializes a new scope from the user and a base scope
      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      # Resolves the scope effectively triggering the query
      def resolve
        scope.all
      end
    end
  end
end
