# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all controllers
  class ApplicationController < ActionController::API
    include Concerns::Correlatable
    include Concerns::Loggable
    include Concerns::Rescuable
    include Concerns::Serializable

    # Returns the current user
    def current_user
      raise NotImplementedError, 'Error: `current_user` method needs to be implemented in your ApplicationController.'
    end

    # GET /health
    def health
      payload = {
        correlation_id: correlation_id,
        db_status: ActiveRecord::Base.connected? ? 'OK' : 'Not Connected',
        environment: Rails.env,
        pid: ::Process.pid
      }

      render json: payload, status: :ok
    end
  end
end
