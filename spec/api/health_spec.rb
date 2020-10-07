# frozen_string_literal: true

RSpec.describe '/health', type: :request do
  it 'returns the health of the application' do
    get '/health'

    expect(parsed_response).to have_key('correlation_id')
    expect(parsed_response).to have_key('db_status')
    expect(parsed_response).to have_key('environment')
    expect(parsed_response).to have_key('pid')
  end
end
