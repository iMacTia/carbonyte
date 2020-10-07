# frozen_string_literal: true

RSpec.describe Carbonyte::ApplicationInteractor do
  class TestInteractor < Carbonyte::ApplicationInteractor
    def call
      context.this_should_be_me = context.current_interactor
    end
  end

  let(:interactor) { TestInteractor.new }

  it 'sets the current_interactor in context before #call' do
    interactor.run
    res = interactor.context
    expect(res.this_should_be_me).to eq(interactor)
  end

  it 'resets the current_interactor in context to nil after #call' do
    interactor.run
    res = interactor.context
    expect(res.current_interactor).to be_nil
  end
end
