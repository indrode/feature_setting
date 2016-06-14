require 'spec_helper'

RSpec.describe FeatureSetting::FsSetting, type: :model do
  # using identical FeatureSetting::Setting class
  let(:fss) { FeatureSetting::Setting }
  describe 'class methods' do
    before do
      stub_const('FeatureSetting::FsSetting::SETTINGS', test: 'value', version: '0.1.0', sym_test: :a_symbol)
      fss.init_settings!
    end

    describe '.settings' do
      it 'returns all defined settings' do
        expect(fss.settings).to be_a(Hash)
        expect(fss.settings).to eq(test: 'value', version: '0.1.0', sym_test: :a_symbol)
      end
    end

    describe '.defined_keys' do
      it 'returns an array of defined setting keys' do
        expect(fss.defined_keys).to eq(%w(test version sym_test))
      end
    end

    describe '.all_stored_keys' do
      it 'should do something'
    end

    describe '.stored_settings' do
      it 'should do something'
    end

    describe '.init_settings!' do
      it 'stores defined settings' do
        expect(fss.count).to eq(3)
        expect(fss.last.key).to eq('sym_test')
      end
    end

    describe '.remove_old_settings!' do
      it 'destroys old settings in database but not defined anymore' do
        fss.create!(key: 'some', klass: 'FeatureSetting::FsSetting', value: 'value')
        expect { fss.remove_old_settings! }.to change { fss.count }.from(4).to(3)
      end
    end

    describe '.key' do
      it 'creates class methods' do
        expect(fss.test).to eq('value')
      end

      it 'created class methods if value is a symbol' do
        expect(fss.sym_test).to eq(:a_symbol)
      end
    end

    describe '.key= setter method' do
      it 'creates a setter method' do
        expect(fss.version).to eq('0.1.0')
        fss.version = '0.1.1'
        expect(fss.version).to eq('0.1.1')
      end
    end

    describe '.reset_settings!' do
      let(:all_settings) { double(:all_settings) }
      it 'should destroy the records for this klass' do
        allow(fss).to receive(:init_settings!)
        expect(all_settings).to receive(:destroy_all).and_return true
        expect(fss).to receive(:where).and_return all_settings
        fss.reset_settings!
      end
    end

    describe '.set!' do
      it 'sets a setting' do
        expect(fss.test).to eq('value')
        fss.set!(:test, 'new value')
        expect(fss.test).to eq('new value')
      end

      it 'works with symbols or strings' do
        fss.set!('test', 'new value')
        expect(fss.test).to eq('new value')
      end

      it 'works when using just a hash' do
        fss.set!(test: 'new value')
        expect(fss.test).to eq('new value')
      end

      it 'sets Array values' do
        fss.set!(test: %w(one two three))
        expect(fss.test).to eq(%w(one two three))
      end

      it 'sets Float values' do
        fss.set!(test: 1.3)
        expect(fss.test).to eq(1.3)
      end

      it 'sets Fixnum values' do
        fss.set!(test: 42)
        expect(fss.test).to eq(42)
      end

      it 'sets Symbol values' do
        fss.set!(test: :ok)
        expect(fss.test).to eq(:ok)
      end

      it 'sets Boolean (FalseClass) values' do
        fss.set!(test: false)
        expect(fss.test).to eq(false)
      end

      it 'sets Boolean (TrueClass) values' do
        fss.set!(test: true)
        expect(fss.test).to eq(true)
      end

      it 'sets nil to false' do
        fss.set!(test: nil)
        expect(fss.test).to eq(false)
      end

      it 'sets hashes as JSON' do
        fss.set!(test: { key1: 123, key2: 345 })
        expect(fss.test).to eq({ 'key1' => 123, 'key2' => 345 })
      end

      it 'returns hashes with_indifferent_access' do
        fss.set!(test: { key1: 123, key2: 345 })
        expect(fss.test[:key1]).to eq(123)
      end
    end

    describe '.existing_key(key, hash)' do
      before do
        allow(fss).to receive(:settings).and_return(key1: '10', key2: '20')
      end

      it 'returns the key' do
        expect(fss.existing_key('key1')).to eq(:key1)
      end

      it 'returns the key if hash is passed' do
        expect(fss.existing_key(nil, key1: '10')).to eq(:key1)
      end

      it 'raises error if key is nil' do
        expect(fss.existing_key(nil, {})).to be_nil
      end

      it 'raises error if key is nil' do
        expect(fss.existing_key).to be_nil
      end
    end
  end
end
