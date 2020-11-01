# frozen_string_literal: true

module ApiHelpers
  def parsed_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  %i[request controller].each do |type|
    config.include ApiHelpers, type: type
  end
end
