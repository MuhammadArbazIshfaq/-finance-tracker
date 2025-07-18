class CreateUserStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :user_stocks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true

      t.timestamps
    end
    
    # Add unique index to prevent duplicate associations
    add_index :user_stocks, [:user_id, :stock_id], unique: true
    
    # Remove user_id from stocks table since we're using join table
    remove_foreign_key :stocks, :users
    remove_index :stocks, :user_id
    remove_column :stocks, :user_id, :integer
  end
end
