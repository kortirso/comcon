class AddCommentForSubscribes < ActiveRecord::Migration[5.2]
  def change
    add_column :subscribes, :comment, :string
  end
end
