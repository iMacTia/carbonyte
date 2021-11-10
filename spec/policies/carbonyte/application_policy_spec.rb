# frozen_string_literal: true

RSpec.describe Carbonyte::ApplicationPolicy do
  let(:test_policy) { Class.new(described_class) }

  let(:policy) { test_policy.new(nil, nil) }
  let(:policy_scope) { test_policy::Scope.new(nil, class_double('ActiveRecord::Base', all: [])) }

  it 'allows all default actions by default' do
    expect(policy).to be_index
    expect(policy).to be_show
    expect(policy).to be_create
    expect(policy).to be_update
    expect(policy).to be_destroy
  end

  it 'provides a default scope by default' do
    expect(policy_scope.resolve).to eq([])
  end
end
