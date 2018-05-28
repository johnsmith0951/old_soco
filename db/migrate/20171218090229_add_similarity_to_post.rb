class AddSimilarityToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :similarity, :text
  end
end
