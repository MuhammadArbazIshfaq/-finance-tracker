class CreateUserStcoks < ActiveRecord::Migration[8.0]
  def change
    create_table :user_stcoks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true

      t.timestamps
    end
  end
end
