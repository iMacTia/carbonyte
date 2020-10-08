# frozen_string_literal: true

RSpec.describe Carbonyte::ApplicationPolicy do
  class TestPolicy < Carbonyte::ApplicationPolicy; end

  let(:policy) { TestPolicy.new(nil, nil) }
  let(:policy_scope) { TestPolicy::Scope.new(nil, double(all: [])) }

  it 'allows all default actions by default' do
    expect(policy.index?).to be_truthy
    expect(policy.show?).to be_truthy
    expect(policy.create?).to be_truthy
    expect(policy.update?).to be_truthy
    expect(policy.destroy?).to be_truthy
  end

  it 'provides a default scope by default' do
    expect(policy_scope.resolve).to eq([])
  end
end
