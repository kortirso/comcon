class AddUserRolesToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :characters, :current_roles, :string, array: true
    change_column_default :characters, :current_roles, []

    Character.all.find_each do |character|
      character.update(current_roles: character.roles.order(main: :desc).pluck(:name).map { |element| [element['en'], element['ru']] })
    end
  end

  def down
    remove_column :characters, :current_roles
  end
end
