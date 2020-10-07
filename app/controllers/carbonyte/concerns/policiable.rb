# frozen_string_literal: true

module Carbonyte
  module Concerns
    # The Policiable concern integrates with Pundit to manage policies
    module Policiable
      include Pundit
    end
  end
end
