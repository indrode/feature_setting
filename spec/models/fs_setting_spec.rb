require 'spec_helper'

RSpec.describe FeatureSetting::FsSetting, type: :model do
  let(:fss) { FeatureSetting::FsSetting }
  describe 'class methods' do
    before do
      stub_const('FeatureSetting::FsSetting::SETTINGS', { test: 'value', version: '0.1.0' })
      fss.init_settings!
    end

    describe '.settings' do
      it 'returns all defined settings' do
        expect(fss.settings).to be_a(Hash)
        expect(fss.settings).to eq({ test: 'value', version: '0.1.0' })
      end
    end

    describe '.defined_settings' do
      it 'returns an array of defined setting keys' do
        expect(fss.defined_settings).to eq(%w(test version))
      end
    end

    describe '.init_settings!' do
      it 'stores defined settings' do
        expect(fss.count).to eq(2)
        expect(fss.last.key).to eq('version')
      end
    end

    describe '.remove_old_settings!' do
      it 'destroys old settings in database but not defined anymore' do
        fss.create!(key: 'some', value: 'value')
        expect { fss.remove_old_settings! }.to change{ fss.count }.from(3).to(2)
      end
    end

    describe '.key' do
      it 'creates class methods' do
          expect(fss.test).to eq('value')
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
    end
  end
end
