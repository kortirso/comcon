class CreateGroupRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :group_roles do |t|
      t.integer :groupable_id
      t.string :groupable_type
      t.jsonb :value, null: false, default: { tanks: { amount: 0, by_class: {} }, healers: { amount: 0, by_class: {} }, dd: { amount: 0, by_class: {} } }
      t.timestamps
    end
    add_index :group_roles, [:groupable_id, :groupable_type]
    add_index :group_roles, :value, using: :gin
  end
end
