require 'spec_helper'

RSpec.describe FeatureSetting::FsFeature, type: :model do
  subject(:fsf) { TestFeature }

  before do
    test_feature = Class.new(described_class)
    features = { test: false, authentication: true }

    stub_const('TestFeature', test_feature)
    stub_const('TestFeature::FEATURES', features)
  end

  describe 'class methods' do
    before do
      fsf.init_features!
    end

    describe '.features' do
      it 'returns all defined features' do
        expect(fsf.features).to be_a(Hash)
        expect(fsf.features).to eq(test: false, authentication: true)
      end
    end

    describe '.defined_features' do
      it 'returns an array of defined feature keys' do
        expect(fsf.defined_features).to eq(%w[test authentication])
      end
    end

    describe '.init_features!' do
      it 'stores defined features' do
        expect(fsf.count).to eq(2)
        expect(fsf.last.key).to eq('authentication')
      end
    end

    describe '.cache_features!' do
      before do
        fsf.cache_features!
      end

      after do
        fsf.init_features!
      end

      it 'creates checker methods' do
        expect(fsf).not_to be_test_enabled
        expect(fsf).to be_authentication_enabled
      end

      it 'caches stored values, ignoring any changes' do
        fsf.enable_test!
        expect(fsf).not_to be_test_enabled
        fsf.disable_authentication!
        expect(fsf).to be_authentication_enabled
      end
    end

    describe '.remove_old_features!' do
      it 'destroys old features in database but not defined anymore' do
        fsf.create!(key: 'new', enabled: true, klass: 'FeatureSetting::FsFeature')
        expect { fsf.remove_old_features! }.to change(fsf, :count).from(3).to(2)
      end
    end

    describe '.reset_features!' do
      it 'creates a new set of features on completion' do
        features = { authentication: true }

        stub_const('TestFeature::FEATURES', features)

        expect { fsf.reset_features! }.to change(fsf, :count).from(2).to(1)
      end
    end

    describe '.key_enabled?' do
      it 'creates enabled? methods' do
        expect(fsf).not_to be_test_enabled
      end

      it 'returns false when feature is deleted after initialization' do
        fsf.enable_test!
        expect(fsf).to be_test_enabled
        fsf.where(key: 'test').first.destroy
        expect(fsf).not_to be_test_enabled
      end
    end

    describe '.enable!' do
      it 'enables a feature' do
        expect(fsf).not_to be_test_enabled
        fsf.enable!(:test)
        expect(fsf).to be_test_enabled
      end

      it 'works with symbols or strings' do
        fsf.enable! 'test'
        expect(fsf).to be_test_enabled
      end

      it 'works when using custom method' do
        fsf.enable_test!
        expect(fsf).to be_test_enabled
        fsf.disable_test!
        expect(fsf).not_to be_test_enabled
      end
    end

    describe '.disable!' do
      it 'disables a feature' do
        fsf.enable!(:test)
        expect(fsf).to be_test_enabled
        fsf.disable!(:test)
        expect(fsf).not_to be_test_enabled
      end

      it 'works with symbols or strings' do
        fsf.disable! 'test'
        expect(fsf).not_to be_test_enabled
      end
    end
  end
end
