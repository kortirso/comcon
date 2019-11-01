class AddSlugToStatics < ActiveRecord::Migration[5.2]
  def change
    add_column :statics, :slug, :string
    add_index :statics, :slug
  end
end
