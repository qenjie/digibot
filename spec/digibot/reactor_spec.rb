describe Digibot::Reactor do
  let(:config) { YAML.load_file('spec/support/fixtures/test_config.yaml') }
  let(:reactor) { Digibot::Reactor.new(config) }

  it 'inits configuration' do
    expect(reactor.instance_variable_get(:@strategy)).to be_instance_of(Digibot::Strategy.strategy_class(config['type']))
  end

  it '#build_dax' do
    reactor.build_dax(config)
    dax = reactor.instance_variable_get(:@dax)

    config['sources'].each do |source|
      expect(dax).to include(source['driver'].to_sym)
    end
  end
end
