# frozen_string_literal: true

RSpec.describe Carbonyte::Concerns::Rescuable, type: :controller do
  class FakePolicy < Carbonyte::ApplicationPolicy
    def index?
      false
    end
  end

  class FakeInteractor < Carbonyte::ApplicationInteractor
    def call
      context.fail!
    end
  end

  controller(ApplicationController) do
    def index
      raise 'Something unpredictable happened.'
    end

    def record_not_found_error
      User.find(-1)
    end

    def policy_not_authorized_error
      authorize(User.new, 'index?', policy_class: FakePolicy)
    end

    def interactor_error
      FakeInteractor.call!(error: 'Something went wrong.')
    end

    def record_invalid_error
      User.create!
    end
  end

  let(:errors) { parsed_response['errors'] }
  let(:error) { errors.first }

  it 'rescues all exceptions inheriting from StandardError' do
    get :index
    expect(errors.size).to eq(1)
    expect(error['code']).to eq('RuntimeError')
    expect(error['detail']).to eq('Something unpredictable happened.')
    expect(error['title']).to eq('Internal Server Error')
  end

  it 'rescues ActiveRecord::RecordNotFound' do
    routes.draw { get :record_not_found_error, to: 'anonymous#record_not_found_error' }
    get :record_not_found_error
    expect(errors.size).to eq(1)
    expect(error['code']).to eq('ActiveRecord::RecordNotFound')
    expect(error['detail']).to eq("Couldn't find User with 'id'=-1")
    expect(error['source']['id']).to eq(-1)
    expect(error['source']['model']).to eq('User')
    expect(error['title']).to eq('Resource Not Found')
  end

  it 'rescues Pundit::NotAuthorizedError' do
    routes.draw { get :policy_not_authorized_error, to: 'anonymous#policy_not_authorized_error' }
    get :policy_not_authorized_error
    expect(errors.size).to eq(1)
    expect(error['code']).to eq('Pundit::NotAuthorizedError')
    expect(error).to have_key('detail')
    expect(error['source']['policy']).to eq('FakePolicy')
    expect(error['title']).to eq('Not Authorized By Policy')
  end

  it 'rescues Interactor::Failure' do
    routes.draw { get :interactor_error, to: 'anonymous#interactor_error' }
    get :interactor_error
    expect(errors.size).to eq(1)
    expect(error['code']).to eq('Interactor::Failure')
    expect(error['detail']).to eq('Something went wrong.')
    expect(error['source']['interactor']).to eq('FakeInteractor')
    expect(error['title']).to eq('Interactor Failure')
  end

  it 'rescues ActiveRecord::RecordInvalid' do
    routes.draw { get :record_invalid_error, to: 'anonymous#record_invalid_error' }
    get :record_invalid_error
    expect(errors.size).to eq(1)
    expect(error['code']).to eq('ActiveRecord::RecordInvalid')
    expect(error['detail']).to eq('can\'t be blank')
    expect(error['source']['pointer']).to eq('attributes/email')
    expect(error['title']).to eq('Invalid Field')
  end
end
