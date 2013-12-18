class CreateSubmission < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :translated_string
      t.string :contributor
      t.timestamps
      t.integer :foreign_word_id
    end

    remove_column :foreign_words, :translated_string
  end
end
