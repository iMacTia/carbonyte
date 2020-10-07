# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all controllers
  class ApplicationController < ActionController::API
    include Concerns::Correlatable
    include Concerns::Loggable
    include Concerns::Policiable
    include Concerns::Rescuable
    include Concerns::Serializable

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
