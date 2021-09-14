require 'spec_helper'

RSpec.describe FeatureSetting::FsSetting, type: :model do
  subject(:fss) { TestSetting }

  before do
    test_setting = Class.new(described_class)
    settings_hash = {
      test: 'value',
      version: '0.1.0',
      sym_test: :a_symbol,
      hash_test: {
        one: :two,
        three: {
          four: :five,
          six: :seven
        }
      }
    }

    stub_const('TestSetting', test_setting)
    stub_const('TestSetting::SETTINGS', settings_hash)
  end

  describe 'class methods' do
    before do
      fss.init_settings!
    end

    describe '.settings' do
      it 'returns all defined settings' do
        expect(fss.settings).to be_a(Hash)
        expect(fss.settings).to eq(
          test: 'value',
          version: '0.1.0',
          sym_test: :a_symbol,
          hash_test: { one: :two, three: { four: :five, six: :seven } }
        )
      end
    end

    describe '.defined_keys' do
      it 'returns an array of defined setting keys' do
        expect(fss.defined_keys).to eq(%w[test version sym_test hash_test])
      end
    end

    describe '.init_settings!' do
      it 'stores defined settings' do
        expect(fss.count).to eq(4)
        expect(fss.last.key).to eq('hash_test')
      end
    end

    describe '.cache_settings!' do
      before do
        fss.cache_settings!
      end

      after do
        fss.set!(:version, '0.1.0')
        fss.reset_settings!
      end

      it 'creates getter methods' do
        expect(fss.test).to eq('value')
        expect(fss.version).to eq('0.1.0')
        expect(fss.hash_test).to eq({ 'one' => 'two', 'three' => { 'four' => 'five', 'six' => 'seven' } })
      end

      it 'caches stored values, ignoring any changes' do
        fss.set!(:version, '3.14')
        expect(fss.version).to eq('0.1.0')
        fss.set!(:hash_test, { a: 'bla' })
        expect(fss.hash_test).to eq({ 'one' => 'two', 'three' => { 'four' => 'five', 'six' => 'seven' } })
      end
    end

    describe '.remove_old_settings!' do
      it 'destroys old settings in database but not defined anymore' do
        fss.create!(key: 'some', klass: 'TestSetting', value: 'value')
        expect { fss.remove_old_settings! }.to change(fss, :count).from(5).to(4)
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

      it 'updates hashes' do
        fss.hash_test = { a: 2 }
        expected_result = { 'one' => 'two', 'three' => { 'four' => 'five', 'six' => 'seven' }, 'a' => 2 }
        expect(fss.hash_test).to eq(expected_result)
      end
    end

    describe '.reset_settings!' do
      it 'creates new set of settings on completion' do
        settings_hash = { test: 'value', version: '0.1.0' }

        stub_const('TestSetting::SETTINGS', settings_hash)

        expect { fss.reset_settings! }.to change(fss, :count).from(4).to(2)
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
        fss.set!(:test, 'new value')
        expect(fss.test).to eq('new value')
      end

      it 'sets Array values' do
        fss.set!(:test, %w[one two three])
        expect(fss.test).to eq(%w[one two three])
      end

      it 'sets Float values' do
        fss.set!(:test, 1.3)
        expect(fss.test).to eq(1.3)
      end

      it 'sets Fixnum values' do
        fss.set!(:test, 42)
        expect(fss.test).to eq(42)
      end

      it 'sets Integer values' do
        fss.set!(:test, 6_512_840)
        expect(fss.test).to eq(6_512_840)
      end

      it 'sets Symbol values' do
        fss.set!(:test, :ok)
        expect(fss.test).to eq(:ok)
      end

      it 'sets Boolean (FalseClass) values' do
        fss.set!(:test, false)
        expect(fss.test).to eq(false)
      end

      it 'sets Boolean (TrueClass) values' do
        fss.set!(:test, true)
        expect(fss.test).to eq(true)
      end

      it 'sets nil to false' do
        fss.set!(:test, nil)
        expect(fss.test).to eq(false)
      end

      it 'sets hashes as JSON' do
        fss.set!(:test, { key1: 123, key2: 345 })
        expect(fss.test).to eq({ 'key1' => 123, 'key2' => 345 })
      end

      it 'returns hashes with_indifferent_access' do
        fss.set!(:test, { key1: 123, key2: 345 })
        expect(fss.test[:key1]).to eq(123)
      end

      it 'can be used called with its alias \'update!\'' do
        fss.update!(:test, { key5: 999 })
        expect(fss.test[:key5]).to eq(999)
      end
    end

    describe '.existing_key(key, hash)' do
      it 'returns the key' do
        expect(fss.existing_key('sym_test')).to eq(:sym_test)
      end

      it 'returns the key if hash is passed' do
        expect(fss.existing_key(nil, sym_test: 'a_symbol')).to eq(:sym_test)
      end

      it 'raises error if key is nil' do
        expect(fss.existing_key(nil, {})).to be_nil
      end

      it 'raises error if key is not passed' do
        expect(fss.existing_key).to be_nil
      end

      it 'returns nil if key does not exist' do
        expect(fss.existing_key('key1')).to be_nil
      end
    end
  end
end
