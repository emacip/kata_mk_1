class AddIndex < ActiveRecord::Migration[7.2]
  def change
    add_index :payments, [:order_id, :created_at]
  end
end
