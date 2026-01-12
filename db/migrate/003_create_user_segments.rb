class CreateUserSegments < ActiveRecord::Migration[7.1]
  def change
    create_table :user_segments do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :segment, null: false, foreign_key: { on_delete: :cascade }
      t.timestamp :assigned_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_index :user_segments, [:user_id, :segment_id], unique: true
  end
end
