# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all interactors
  class ApplicationInteractor
    include Interactor

    # Interactor hooks are not inherited by subclasses, so we need a hack.
    # @see https://github.com/collectiveidea/interactor/issues/114
    def self.inherited(klass)
      super
      klass.class_eval do
        before do
          context.current_interactor = self
        end

        after do
          context.current_interactor = nil
        end
      end
    end
  end
end
