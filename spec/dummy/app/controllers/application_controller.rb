# frozen_string_literal: true

class ApplicationController < Carbonyte::ApplicationController
  def current_user
    User.first
  end
end
