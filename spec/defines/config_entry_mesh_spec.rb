require 'spec_helper'

describe 'consul::config_entry::mesh' do
  let(:title) { 'whatever' }
  let(:params) { { transparent_proxy: { 'MeshDestinationsOnly' => true } } }

  it { is_expected.to compile.with_all_deps }

  it 'always names the entry mesh' do
    is_expected.to contain_consul_config_entry('mesh/mesh').with(ensure: 'present', config: { 'TransparentProxy' => { 'MeshDestinationsOnly' => true } })
  end

  context 'without parameters' do
    let(:params) { {} }

    it { is_expected.to contain_consul_config_entry('mesh/mesh').with_config({}) }
  end

  context 'with ensure absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_consul_config_entry('mesh/mesh').with_ensure('absent') }
  end

  context 'with a non boolean MeshDestinationsOnly' do
    let(:params) { { transparent_proxy: { 'MeshDestinationsOnly' => 'yes' } } }

    it { is_expected.to compile.and_raise_error(%r{MeshDestinationsOnly}) }
  end
end
