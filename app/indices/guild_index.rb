ThinkingSphinx::Index.define :guild, with: :real_time do
  # indexes
  indexes name, type: :string

  # attributes
  has fraction_id, type: :integer
  has world_id, type: :integer

  # properties
  set_property min_infix_len: 3
end
