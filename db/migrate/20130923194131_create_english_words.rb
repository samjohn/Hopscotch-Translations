class CreateEnglishWords < ActiveRecord::Migration
  def change
    create_table :english_words do |t|
      t.text :translatable_string
      t.text :comment

      t.timestamps
    end
  end
end
