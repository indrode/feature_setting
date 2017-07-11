class CreateFsTables < ActiveRecord::Migration[4.2]
  def self.up
    create_table :fs_features do |t|
      t.string :key
      t.boolean :enabled, default: false
      t.string :klass
      t.timestamps null: false
    end

    create_table :fs_settings do |t|
      t.string :key
      t.text :value
      t.string :value_type
      t.string :klass
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :fs_features
    drop_table :fs_settings
  end
end
