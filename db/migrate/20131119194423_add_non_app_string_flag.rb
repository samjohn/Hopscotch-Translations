class AddNonAppStringFlag < ActiveRecord::Migration
  def change
    add_column :english_words, :non_app_string, :boolean
  end
end
