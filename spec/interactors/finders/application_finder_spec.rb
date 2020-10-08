# frozen_string_literal: true

RSpec.describe Carbonyte::Finders::ApplicationFinder do
  class TestFinder < Carbonyte::Finders::ApplicationFinder
    ALLOWED_INCLUDES = %i[field1 field2].freeze

    def can_include?(rel)
      ALLOWED_INCLUDES.include?(rel)
    end
  end

  let(:params) { {} }
  let(:scope) { double }
  let(:finder) { TestFinder.new(scope: scope, params: params) }

  before do
    allow(scope).to receive(:limit).and_return(scope)
    allow(scope).to receive(:page).and_return(scope)
  end

  it 'does not include any relation by default' do
    expect(described_class.new.can_include?(:any)).to be_falsey
  end

  it 'automatically paginates the result with default values' do
    expect(scope).to receive(:limit).with(25).and_return(scope)
    expect(scope).to receive(:page).with(1).and_return(scope)
    finder.run
  end

  context 'with include param' do
    let(:params) { { include: 'field1,field2' } }

    it 'automatically includes relations' do
      expect(scope).to receive(:includes).with(:field1).and_return(scope)
      expect(scope).to receive(:includes).with(:field2).and_return(scope)
      finder.run
    end
  end

  context 'with sort param' do
    let(:params) { { sort: 'field1,-field2' } }

    it 'automatically sorts the result' do
      expect(scope).to receive(:order).with(:field1).and_return(scope)
      expect(scope).to receive(:order).with({ field2: :desc }).and_return(scope)
      finder.run
    end
  end

  context 'with page and limit params' do
    let(:params) { { limit: 10, page: 10 } }

    it 'paginates the result based on settings' do
      expect(scope).to receive(:limit).with(10).and_return(scope)
      expect(scope).to receive(:page).with(10).and_return(scope)
      finder.run
    end
  end
end
