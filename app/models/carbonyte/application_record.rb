# frozen_string_literal: true

module Carbonyte
  # Carbonyte base class for all models
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
