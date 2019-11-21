class UpdateUsersConfirmations < ActiveRecord::Migration[5.2]
  def change
    User.update_all(confirmed_at: DateTime.now)
  end
end
