require 'spec_helper'

RSpec.describe FeatureSetting::FsFeature, type: :model do
  let(:fsf) { FeatureSetting::FsFeature }

  describe 'class methods' do
    before do
      stub_const('FeatureSetting::FsFeature::FEATURES', { test: false, authentication: true })
      fsf.init_features!
    end

    describe '.features' do
      it 'returns all defined features' do
        expect(fsf.features).to be_a(Hash)
        expect(fsf.features).to eq({ test: false, authentication: true })
      end
    end

    describe '.defined_features' do
      it 'returns an array of defined feature keys' do
        expect(fsf.defined_features).to eq(%w(test authentication))
      end
    end

    describe '.init_features!' do
      it 'stores defined features' do
        expect(fsf.count).to eq(2)
        expect(fsf.last.key).to eq('authentication')
      end
    end

    describe '.remove_old_features!' do
      it 'destroys old features in database but not defined anymore' do
        fsf.create!(key: 'new', enabled: true)
        expect { fsf.remove_old_features! }.to change{ fsf.count }.from(3).to(2)
      end
    end

    describe '.key_enabled?' do
      it 'creates enabled? methods' do
        expect(fsf.test_enabled?).to be_falsey
      end
    end

    describe '.enable!' do
      it 'enables a feature' do
        expect(fsf.test_enabled?).to be_falsey
        fsf.enable!(:test)
        expect(fsf.test_enabled?).to be_truthy
      end

      it 'works with symbols or strings' do
        fsf.enable! 'test'
        expect(fsf.test_enabled?).to be_truthy
      end
    end

    describe '.disable!' do
      it 'disables a feature' do
        fsf.enable!(:test)
        expect(fsf.test_enabled?).to be_truthy
        fsf.disable!(:test)
        expect(fsf.test_enabled?).to be_falsey
      end

      it 'works with symbols or strings' do
        fsf.disable! 'test'
        expect(fsf.test_enabled?).to be_falsey
      end
    end
  end
end
