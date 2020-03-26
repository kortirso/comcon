class AddMainToCharacters < ActiveRecord::Migration[5.2]
  def change
    add_column :characters, :main, :boolean
    change_column_default :characters, :main, from: nil, to: false

    User.all.find_each do |user|
      next if user.characters.empty?

      user.characters.order(level: :desc, item_level: :desc).first.update(main: true)
    end
  end
end
