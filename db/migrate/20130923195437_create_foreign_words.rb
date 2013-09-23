class CreateForeignWords < ActiveRecord::Migration
  def change
    create_table :foreign_words do |t|
      t.text :translatable_string
      t.string :language
      t.text :translated_string

      t.timestamps
    end

    add_index :foreign_words, :
    add_index :foreign_words, [:translatable_string, :language], unique: true
    add_index :english_words, :translatable_string, unique: true
  end
end
