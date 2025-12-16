# frozen_string_literal: true

class ConvertUsersToUuid < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    rename_table :users, :legacy_users

    create_table :users, id: :uuid do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :jti,                null: false, default: -> { "gen_random_uuid()" }

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :jti,                  unique: true
    add_index :users, :reset_password_token, unique: true

    execute <<~SQL
      INSERT INTO users (id, email, encrypted_password, jti, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at)
      SELECT gen_random_uuid(), email, encrypted_password, COALESCE(jti, gen_random_uuid()::text), reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at
      FROM legacy_users
    SQL

    drop_table :legacy_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
