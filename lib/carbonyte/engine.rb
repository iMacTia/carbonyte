# frozen_string_literal: true

require 'carbonyte/initializers'
require 'interactor/rails'
require 'jsonapi/serializer'
require 'pundit'

module Carbonyte
  # Carbonyte Engine
  class Engine < ::Rails::Engine
    isolate_namespace Carbonyte

    include Initializers::Lograge
    include Initializers::Sidekiq

    initializer 'carbonyte.catch_404' do
      config.after_initialize do |app|
        app.routes.append { match '*path', to: 'carbonyte/application#route_not_found', via: :all }
      end
    end
  end
end
