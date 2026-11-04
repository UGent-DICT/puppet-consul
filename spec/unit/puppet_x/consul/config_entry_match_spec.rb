require 'spec_helper'
require_relative '../../../../lib/puppet_x/consul/config_entry_match'

describe PuppetX::Consul::ConfigEntryMatch do
  def match?(should, is, unordered = [])
    described_class.subset?(should, is, unordered)
  end

  it 'matches equal scalars and rejects different ones' do
    expect(match?('a', 'a')).to be(true)
    expect(match?('a', 'b')).to be(false)
    expect(match?(8200, 8200)).to be(true)
    expect(match?(true, false)).to be(false)
  end

  describe 'durations' do
    it 'matches a duration string with the nanoseconds Consul returns' do
      expect(match?({ 'RequestTimeout' => '30s' }, { 'RequestTimeout' => 30_000_000_000 })).to be(true)
      expect(match?({ 'RequestTimeout' => '1m30s' }, { 'RequestTimeout' => 90_000_000_000 })).to be(true)
      expect(match?({ 'RequestTimeout' => '1.5s' }, { 'RequestTimeout' => 1_500_000_000 })).to be(true)
      expect(match?({ 'IdleTimeout' => '250ms' }, { 'IdleTimeout' => 250_000_000 })).to be(true)
    end

    it 'detects a different duration' do
      expect(match?({ 'RequestTimeout' => '30s' }, { 'RequestTimeout' => 31_000_000_000 })).to be(false)
      expect(match?({ 'RequestTimeout' => '30s' }, { 'RequestTimeout' => 0 })).to be(false)
    end

    it 'does not treat other strings as durations' do
      expect(match?({ 'Name' => 'web' }, { 'Name' => 5 })).to be(false)
      expect(match?({ 'Weight' => '10' }, { 'Weight' => 10 })).to be(false)
    end
  end

  it 'ignores keys that only Consul sets' do
    should = { 'Listeners' => [{ 'Port' => 8200, 'Protocol' => 'tcp' }] }
    is = { 'Listeners' => [{ 'Port' => 8200, 'Protocol' => 'tcp', 'Name' => '' }], 'CreateIndex' => 12, 'ModifyIndex' => 15, 'Hash' => 123 }
    expect(match?(should, is)).to be(true)
  end

  it 'fails when a wanted key is missing or differs' do
    expect(match?({ 'Port' => 1 }, {})).to be(false)
    expect(match?({ 'Port' => 1 }, { 'Port' => 2 })).to be(false)
    expect(match?({ 'Port' => 1 }, nil)).to be(false)
  end

  it 'only matches a nil value against an absent key' do
    expect(match?({ 'Meta' => nil }, {})).to be(true)
    expect(match?({ 'Meta' => nil }, { 'Meta' => { 'a' => 'b' } })).to be(false)
  end

  it 'requires arrays to have the same length' do
    expect(match?({ 'L' => [1] }, { 'L' => [1, 2] })).to be(false)
    expect(match?({ 'L' => [1, 2] }, { 'L' => [1] })).to be(false)
  end

  it 'compares arrays element-wise by default' do
    expect(match?({ 'L' => [1, 2] }, { 'L' => [2, 1] })).to be(false)
  end

  describe 'unordered_keys' do
    let(:wanted) { { 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }, { 'Name' => 'web', 'Action' => 'deny' }] } }
    let(:is) { { 'Sources' => [{ 'Name' => 'web', 'Action' => 'deny', 'Precedence' => 9 }, { 'Name' => 'api', 'Action' => 'allow', 'Precedence' => 9 }] } }

    it 'ignores the order of the listed keys' do
      expect(match?(wanted, is, ['Sources'])).to be(true)
    end

    it 'still fails on differing content' do
      is['Sources'][0]['Action'] = 'allow'
      expect(match?(wanted, is, ['Sources'])).to be(false)
    end

    it 'applies to nested keys' do
      expect(match?({ 'Outer' => [{ 'Sources' => [1, 2] }] }, { 'Outer' => [{ 'Sources' => [2, 1] }] }, ['Sources'])).to be(true)
    end

    it 'backtracks when a lenient element matches several elements' do
      lenient = { 'Sources' => [{ 'Action' => 'allow' }, { 'Name' => 'api', 'Action' => 'allow' }] }
      actual = { 'Sources' => [{ 'Name' => 'api', 'Action' => 'allow' }, { 'Name' => 'web', 'Action' => 'allow' }] }
      expect(match?(lenient, actual, ['Sources'])).to be(true)
    end
  end
end
