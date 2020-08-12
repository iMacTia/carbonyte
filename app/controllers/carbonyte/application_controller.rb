# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all controllers
  class ApplicationController < ActionController::API
    include Concerns::Correlatable
    include Concerns::Loggable
    include Concerns::Rescuable
    include Concerns::Serializable
  end
end
