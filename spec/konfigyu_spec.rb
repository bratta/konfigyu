# frozen_string_literal: true

RSpec.describe Konfigyu do
  it 'has a version number' do
    expect(Konfigyu::VERSION).not_to be nil
  end

  describe 'without a configuration file' do
    it 'raises an exception when the file does not exist' do
      expect { Konfigyu::Config.new }.to raise_error(Konfigyu::FileNotFoundException)
    end
  end

  describe 'with a configuration file' do
    let!(:config_file) { File.expand_path(File.join(__dir__, 'fixtures', 'konfigyu.yml')) }
    let(:config) { Konfigyu::Config.new(config_file) }

    it 'loads the file without raising an exception' do
      expect { Konfigyu::Config.new(config_file) }.not_to raise_error
    end

    describe '#validate' do
      it 'raises an error if a required field is not present' do
        config.options = {
          required_fields: ['not_present'],
          required_values: {}
        }
        expect { config.validate }.to raise_error(Konfigyu::InvalidConfigException)
      end

      it 'does not raise an error if all required fields are present' do
        config.options = {
          required_fields: ['foo', 'foo.bar', 'foo.boo'],
          required_values: {}
        }
        expect { config.validate }.not_to raise_error
      end

      it 'raises an error if a required value is not present' do
        config.options = {
          required_fields: ['log', 'log.level'],
          required_values: { 'log.level': %w[none fatal error] }
        }
        expect { config.validate }.to raise_error(Konfigyu::InvalidConfigException)
      end

      it 'does not raise an error if a field has a required value' do
        config.options = {
          required_fields: ['log', 'log.level'],
          required_values: { 'log.level': %w[none fatal error warn info debug] }
        }
        expect { config.validate }.not_to raise_error
      end

      it 'handles non-required fields with required values' do
        config.options = {
          required_fields: [],
          required_values: { 'log.level': %w[none fatal error warn info debug] }
        }
        config.data.log.level = 'foo'
        expect { config.validate }.to raise_error(Konfigyu::InvalidConfigException)
        config.data.log.level = nil
        expect { config.validate }.not_to raise_error
      end
    end

    describe 'data retrieval' do
      let(:config) { Konfigyu::Config.new(config_file) }

      it 'exposes config through .data' do
        expect(config.data.foo.bar).to eq('baz')
        expect(config.data.foo.bif).to be_nil
      end

      it 'exposes config through []' do
        expect(config['foo.bar']).to eq('baz')
        expect(config['foo.bar.bif']).to be_nil
      end

      it 'responds to config keys as methods' do
        expect(config).to respond_to(:foo)
        expect(config).to respond_to(:'foo.bar')
      end

      it 'does not respond to normal missing methods' do
        expect(config).not_to respond_to(:bar)
      end

      it 'utilizes method_missing to get the data directly' do
        expect(config.foo.bar).to eq('baz')
        expect(config.foo.bif).to be_nil
      end

      it 'raises an error if the config key does not exist' do
        expect { config.bar }.to raise_error(NameError)
      end
    end
  end

  describe 'private methods' do
    let!(:config_file) { File.expand_path(File.join(__dir__, 'fixtures', 'konfigyu.yml')) }
    let(:config) { Konfigyu::Config.new(config_file) }

    describe '#initialize_options' do
      it 'has a sane set of defaults' do
        expect(config.send(:initialize_options)).to eq(config.send(:default_options))
      end

      it 'filters options for required keys' do
        unfiltered = {
          required_fields: [:foo],
          should_be_filtered: 'invalid'
        }
        expect(config.send(:initialize_options, unfiltered)).to eq(
          required_fields: [:foo],
          required_values: {}
        )
      end

      it 'symbolizes keys passed in' do
        unfiltered = {
          "required_fields": [:foo],
          "required_values": {}
        }
        expect(config.send(:initialize_options, unfiltered)).to eq(
          required_fields: [:foo],
          required_values: {}
        )
      end
    end

    describe '#deep_key_exists?' do
      it 'returns a true value if a deep key is found' do
        expect(config.send(:deep_key_exists?, 'foo.bar')).to be_truthy
      end

      it 'does not raise an exception if tree structure not found' do
        expect { config.send(:deep_key_exists?, 'blip.blop.bloop') }.not_to raise_error
      end

      it 'returns a false value if a deep key is not found' do
        expect(config.send(:deep_key_exists?, 'foo.fizz')).to be_falsey
      end
    end
  end
end
