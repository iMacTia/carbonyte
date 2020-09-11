# frozen_string_literal: true

Carbonyte::Engine.routes.draw do
  get :health, controller: :application, via: :all
end
