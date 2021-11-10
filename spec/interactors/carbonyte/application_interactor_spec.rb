# frozen_string_literal: true

RSpec.describe Carbonyte::ApplicationInteractor do
  let(:test_interactor) do
    Class.new(Carbonyte::ApplicationInteractor) do
      def call
        context.this_should_be_me = context.current_interactor
      end
    end
  end

  let(:interactor) { test_interactor.new }

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
