class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :status, null: false
      t.integer :amount_cents
      t.timestamps
    end
  end
end
