# feature_setting

[![Gem
Version](https://badge.fury.io/rb/feature_setting.svg)](https://badge.fury.io/rb/feature_setting)
[![Code
Climate](https://codeclimate.com/github/indrode/feature_setting/badges/gpa.svg)](https://codeclimate.com/github/indrode/feature_setting)
[![Test
Coverage](https://codeclimate.com/github/indrode/feature_setting/badges/coverage.svg)](https://codeclimate.com/github/indrode/feature_setting/coverage)
[![security](https://hakiri.io/github/indrode/feature_setting/master.svg)](https://hakiri.io/github/indrode/feature_setting/master)

This gem introduces the concept of "features" and "settings" to your Rails app. It provides an easy way to define such features and settings with default values right in your code and will persist them in the database.

- a feature is a key that can either be enabled or disabled
- a setting is a key that has a value (of type String, Fixnum, Float, Array, or Hash)

In practice, features can be used to switch certain functionality in your code on or off. This can be used to roll out functionality without the need to deploy. Settings are very flexible in that they can hold any value. The possibilities are endless. They should not be used to store application secrets, such as tokens, passwords, and keys. Those type of settings should rather be stored in environment variables using tools like [https://github.com/bkeepers/dotenv](dotenv).

Both, features and settings are configured in your code with default values. They can then be updated at any time in the Rails console and persist in the database.

```ruby
# using features:
if Feature.caching_enabled?
  # do this
else
  # do that
end

# using settings:
if Setting.error_threshold > 500
    # do this
end

if Setting.allowed_users.include?(current_user.id)
  # do that
end
```

## Installation

Add the gem to your application's Gemfile:

```ruby
gem 'feature_setting'
```

Now run the `feature_setting` installation:

    $ rails generate feature_setting:install

This generates a migration file. To run this migration:

    $ rake db:migrate

The next step is to define your Feature and/or Setting classes.


## Usage

### Features

To create a new Feature class, inherit a class from `FeatureSetting::Feature` (if using a gem version prior to `1.2.0` use `FeatureSetting::FsFeature`). Then define your features in a hash called `FEATURES` and call `init_features!`.

```ruby
class Features < FeatureSetting::Feature
  FEATURES = {
    newfeature: true
  }

  init_features!
end
```
**Note:** You can call `init_features!(true)` to remove any existing features that are not defined anymore

For each key you have defined, a class method `keyname_enabled?` is generated. You can now do the following:

```ruby
Features.newfeature_enabled? # => true
Features.disable!(:newfeature)
Features.newfeature_enabled? # => false
Features.enable!(:newfeature)
Features.newfeature_enabled? # => true
```

Or you can use these shortcuts:

```ruby
Features.enable_newfeature!
Features.disable_newfeature!
```

Default values for features are defined in your class and current values are persisted in the database.


### Settings

To create a new Setting class, inherit a class from `FeatureSetting::Setting` (if using a gem version prior to `1.2.0` use `FeatureSetting::FsSetting`). Then define your settings in a hash called `SETTINGS` and call `init_settings!`. The following example shows the setup and some possible definitions.

```ruby
class Settings < FeatureSetting::Setting
  SETTINGS = {
    setting_one:   12300,
    setting_two:   'some string',
    setting_three: %w(one two three),
    setting_four:  ENV['SETTING_FOUR'],
    setting_five:  { key1: 'value1', key2: 'value2' }
    setting_six:   true
  }

  init_settings!
end
```

**Note:** You can call `init_settings!(true)` to remove any existing settings that are not defined anymore

You can now do the following:

```ruby
Settings.setting_one # => 12300
Settings.setting_one = 2000
Settings.setting_one # => 2000
```

**NEW IN VERSION 1.6:** Hashes values can be updated individually and will not overwrite the entire hash:
```ruby
Settings.setting_five = { key1: 'another_value' }
=> setting_five:  { key1: 'another_value', key2: 'value2' }

Settings.setting_five = { key3: 'value3' }
=> setting_five:  { key1: 'another_value', key2: 'value2', key3: 'value3' }
```

Default values for settings are defined in your class and current values are persisted in the database.

Settings support the following datatypes:

```
Boolean
String
Integer
Float
Symbol
Array
Hash
```

### Advanced Features

Settings and features can be reset to their default values as configured in your class definition:

```ruby
Features.reset_features!
Settings.reset_settings!
```

Display all defined keys:

```ruby
Features.defined_features
Settings.defined_settings
```

Cache settings or features:

```ruby
Features.cache_features!
Settings.cache_settings!
```
Note that a simple call to `Features.init_features!` or `Settings.init_settings!` respectively will remove caching.

You can create as many Setting or Feature classes as you desire. Here are some examples:

```ruby
SearchSettings.levenshtein_distance
TestFeatures.experimental_search_enabled?
```

## Contributing

1. Fork it (https://github.com/indrode/feature_setting/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Notes:

- Contributions without tests won't be accepted.
- Please don't update the gem version.


## License

The MIT License (MIT)

Copyright (c) 2015, 2016, 2017, 2018, 2019 Indro De ([http://indrode.com](http://indrode.com))

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
