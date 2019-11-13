class AddDefaultTimeOffsetsForUsers < ActiveRecord::Migration[5.2]
  def change
    User.all.each do |user|
      time_offset_form = TimeOffsetForm.new(user: user, value: nil)
      time_offset_form.persist?
    end
  end
end
