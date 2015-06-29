class CreateFsTables < ActiveRecord::Migration
  def self.up
    create_table :fs_features do |t|
      t.string :key
      t.boolean :enabled, default: false
      t.string :klass
      t.timestamps null: false
    end

    create_table :fs_settings do |t|
      t.string :key
      t.string :value
      t.string :value_type
      t.string :klass
      t.timestamps null: false
    end
  end
end
