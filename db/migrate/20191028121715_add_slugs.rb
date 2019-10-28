class AddSlugs < ActiveRecord::Migration[5.2]
  def change
    Event.find_each(&:save)
    Guild.find_each(&:save)
  end
end
