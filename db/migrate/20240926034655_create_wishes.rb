class CreateWishes < ActiveRecord::Migration[7.0]
  def change
    create_table :wishes do |t|
      t.string :title, null: false
      t.string :content

      t.timestamps
    end
  end
end
