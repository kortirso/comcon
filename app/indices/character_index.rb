# frozen_string_literal: true

ThinkingSphinx::Index.define :character, with: :real_time do
  # indexes
  indexes name, type: :string
  indexes guild.name, as: :guild_name

  # attributes
  has race_id, type: :integer
  has world_id, type: :integer
  has character_class_id, type: :integer

  # properties
  set_property min_infix_len: 3
end
