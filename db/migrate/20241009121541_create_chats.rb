class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title,   null: false
      t.text   :content, null: false
      t.string :request

      t.timestamps
    end
  end
end
