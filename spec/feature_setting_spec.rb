require 'spec_helper'

describe FeatureSetting do
  it 'has a version number' do
    expect(FeatureSetting::VERSION).not_to be nil
  end
end
