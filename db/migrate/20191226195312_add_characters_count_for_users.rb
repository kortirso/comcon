class AddCharactersCountForUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :characters_count, :integer

    User.find_each { |user| User.reset_counters(user.id, :characters) }
  end
end
