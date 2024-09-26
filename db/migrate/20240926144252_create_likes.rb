class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :wish, null: false, foreign_key: true
      t.integer :count

      t.timestamps
    end
  end
end
