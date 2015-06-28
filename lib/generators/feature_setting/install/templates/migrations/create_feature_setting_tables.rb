class CreateFeatureSettingTables.rb < ActiveRecord::Migration
  def self.up
    create_table :fs_features do |t|
      t.string :key
      t.boolean :enabled, default: false

      t.timestamps null: false
    end

    create_table :fs_settings do |t|
      t.string :key
      t.string :value

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :fs_jobs
    drop_table :fs_settings
  end
end
