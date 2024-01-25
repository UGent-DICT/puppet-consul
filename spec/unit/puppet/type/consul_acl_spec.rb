require 'spec_helper'

describe Puppet::Type.type(:consul_acl) do
  samplerules = {
    'key' => {
      'test' => {
        'policy' => 'read'
      }
    }
  }

  it 'fails if type is not client or management' do
    expect {
      Puppet::Type.type(:consul_acl).new(name: 'foo', type: 'blah')
    }.to raise_error(Puppet::Error, %r{Invalid value})
  end

  it 'fails if rules is not a hash' do
    expect {
      Puppet::Type.type(:consul_acl).new(name: 'foo', rules: 'blah')
    }.to raise_error(Puppet::Error, %r{ACL rules must be provided as a hash})
  end

  it 'fails if no name is provided' do
    expect {
      Puppet::Type.type(:consul_acl).new(type: 'client')
    }.to raise_error(Puppet::Error, %r{Title or name must be provided})
  end

  context 'with type and rules provided' do
    before(:each) do
      @acl = Puppet::Type.type(:consul_acl).new(
        name: 'testing',
        type: 'management',
        rules: samplerules,
      )
    end

    it 'accepts a type' do
      expect(@acl[:type]).to eq(:management)
    end

    it 'defaults to localhost' do
      expect(@acl[:hostname]).to eq('localhost')
    end

    it 'accepts a hash of rules' do
      expect(@acl[:rules]).to eq(samplerules)
    end

    it 'defaults to http' do
      expect(@acl[:protocol]).to eq(:http)
    end
  end
end
