# frozen_string_literal: true

RSpec.describe Carbonyte::Concerns::Serializable, type: :controller do
  class FakeSerializer < Carbonyte::ApplicationSerializer
    attributes :name, :age
  end

  class AlternativeFakeSerializer < Carbonyte::ApplicationSerializer
    set_type :fake
    attributes :name
  end

  class Fake
    attr_accessor :id, :name, :age
  end

  controller(ApplicationController) do
    def fake
      Fake.new.tap do |f|
        f.id = 1
        f.name = 'test'
        f.age = 20
      end
    end

    def inferred
      serialize(fake)
    end

    def explicit
      serialize(fake, serializer_class: AlternativeFakeSerializer, status: :created)
    end

    def list
      serialize([fake, fake])
    end
  end

  it 'infers the serializer type automatically when not specified' do
    expect(FakeSerializer).to receive(:new).and_call_original
    routes.draw { get :inferred, to: 'anonymous#inferred' }
    get :inferred
    expect(response.status).to eq(200)
  end

  it 'allows to customize the serializer type and status' do
    expect(AlternativeFakeSerializer).to receive(:new).and_call_original
    routes.draw { get :explicit, to: 'anonymous#explicit' }
    get :explicit
    expect(response.status).to eq(201)
  end

  it 'automatically passes include options to serializer' do
    object_matcher = instance_of(Fake)
    options_matcher = hash_including(include: %i[field1 field2])
    expect(FakeSerializer).to receive(:new)
      .with(object_matcher, options_matcher)
      .and_call_original
    routes.draw { get :inferred, to: 'anonymous#inferred' }
    get :inferred, params: { include: 'field1,field2' }
  end

  it 'works with lists as well' do
    expect(FakeSerializer).to receive(:new).and_call_original
    routes.draw { get :list, to: 'anonymous#list' }
    get :list
    expect(response.status).to eq(200)
  end
end
