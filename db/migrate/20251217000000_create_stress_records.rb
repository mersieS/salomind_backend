class CreateStressRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :stress_records do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :mood, null: false
      t.integer :stress_feeling, null: false
      t.integer :heart_rate, null: false
      t.integer :physical_fatigue, null: false
      t.float :sleep_hours, null: false
      t.integer :sleep_quality, null: false
      t.integer :caffeine_intake, null: false
      t.float :screen_time, null: false
      t.integer :stress_score, null: false
      t.string :stress_level, null: false

      t.timestamps
    end
  end
end
