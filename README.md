# feature_setting

[![Code Climate](https://codeclimate.com/github/indrode/feature_setting/badges/gpa.svg)](https://codeclimate.com/github/indrode/feature_setting)

**This gem is under development and has not been pushed!**

## Installation

Add the gem to your application's Gemfile:

```ruby
gem 'feature_setting'
```

And then execute:

    $ rails feature_setting:install

This generates a migration file. To run this migration:

    $ rake db:migrate

## Features

To create a new Feature class, inherit your class from `FeatureSetting::FsFeature`. Then define your features and call `init_features!`.

```ruby
class MyFeatures < FeatureSetting::FsFeature
  FEATURES = { newfeature: true }
  init_features!
end
```

You can now do the following things:

```ruby
MyFeatures.newfeature_enabled? # => true
MyFeatures.disable!(:newfeature)
MyFeatures.newfeature_enabled? # => false
MyFeatures.enable!(:newfeature)
MyFeatures.newfeature_enabled? # => true
```

Default values for features are defined in your class and persisted in the database.

## Settings

To create a new Setting class, inherit your class from `FeatureSetting::FsSetting`. Then define your settings and call `init_settings!`.

```ruby
class MySettings < FeatureSetting::FsSetting
  SETTINGS = { newsetting: 12300 }
  init_settings!
end
```

You can now do the following things:

```ruby
MySettings.newsetting # => 12300
MySettings.set!(newsetting: 1000)
MySettings.newsetting # => 1000

# additional ways to set setting values
MySettings.set!(:newsetting, 1000)
MySettings.set!('newsetting', 1000)
```

Default values for settings are defined in your class and persisted in the database.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/indrode/feature_setting/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
