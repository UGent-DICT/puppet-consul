require 'spec_helper'

describe Puppet::Type.type(:consul_intention) do
  it 'defaults ensure to present' do
    intention = Puppet::Type.type(:consul_intention).new(name: 'web')
    expect(intention[:ensure]).to eq(:present)
  end

  it 'accepts valid sources' do
    intention = Puppet::Type.type(:consul_intention).new(
      name: 'web',
      sources: [
        { 'name' => 'api', 'action' => 'allow' },
        { 'name' => '*', 'action' => 'deny' },
      ],
    )
    expect(intention[:sources]).to eq([{ 'name' => 'api', 'action' => 'allow' }, { 'name' => '*', 'action' => 'deny' }])
  end

  it 'fails if a source is not a hash' do
    expect do
      Puppet::Type.type(:consul_intention).new(name: 'web', sources: ['api'])
    end.to raise_error(Puppet::Error, %r{Intention source must be a hash})
  end

  it 'fails if a source name is missing' do
    expect do
      Puppet::Type.type(:consul_intention).new(name: 'web', sources: [{ 'action' => 'allow' }])
    end.to raise_error(Puppet::Error, %r{Intention source name must be a string})
  end

  it 'fails if a source action is invalid' do
    expect do
      Puppet::Type.type(:consul_intention).new(name: 'web', sources: [{ 'name' => 'api', 'action' => 'permit' }])
    end.to raise_error(Puppet::Error, %r{Intention source action must be 'allow' or 'deny'})
  end

  it 'fails on unknown source keys' do
    expect do
      Puppet::Type.type(:consul_intention).new(name: 'web', sources: [{ 'name' => 'api', 'action' => 'allow', 'permissions' => [] }])
    end.to raise_error(Puppet::Error, %r{Unknown intention source keys: permissions})
  end

  it 'ignores source ordering when comparing' do
    intention = Puppet::Type.type(:consul_intention).new(
      name: 'web',
      sources: [
        { 'name' => 'api', 'action' => 'allow' },
        { 'name' => 'db', 'action' => 'deny' },
      ],
    )
    is = [{ 'name' => 'db', 'action' => 'deny' }, { 'name' => 'api', 'action' => 'allow' }]
    expect(intention.property(:sources).insync?(is)).to be(true)
  end
end
