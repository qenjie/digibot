describe Digibot::Command do
  let(:config) { YAML.load_file('config/strategy.yaml')['strategy'] }

  it 'loads configuration' do
    Digibot::Command.load_configuration

    expect(Digibot::Configuration.get(:strategy)).to eq(config)
  end
end
