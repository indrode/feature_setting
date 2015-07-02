# Changelog

## v1.2.0

- change parent class names to `FeatureSetting::Feature` and `FeatureSetting::Setting` (the old `FsFeature` and `FsSetting` can still be used as well)

## v1.1.0

- dynamically generate setter methods for FsSetting keys to simplify updating values:

```ruby
MySetting.setting_key = 123
```

## v1.0.0

- public release
