# frozen_string_literal: true

require 'sidekiq/testing'
Sidekiq::Testing.server_middleware do |chain|
  chain.add Carbonyte::Initializers::Sidekiq::Middleware::LoadRequestStore
end

RSpec.describe Carbonyte::ApplicationWorker do
  class TestWorker < Carbonyte::ApplicationWorker
    def perform
      logger.info("user_id: #{current_user_id}, corr_id: #{correlation_id}")
    end
  end

  # def process(worker, params = [], encrypt: false)
  #   msg = Sidekiq.dump_json({ 'class' => worker.to_s, 'args' => params, 'encrypt' => encrypt })
  #   work = Sidekiq::BasicFetch::UnitOfWork.new('queue:default', msg)
  #   processor.send(:process, work)
  # end

  before do
    RequestStore.store[:current_user_id] = 123
    RequestStore.store[:correlation_id] = 'abc'
  end

  it 'allows to access current_user_id and correlation_id' do
    expect(Sidekiq.logger).to receive(:info)
      .with('user_id: 123, corr_id: abc')
    Sidekiq::Testing.inline! do
      TestWorker.perform_async
    end
  end
end
