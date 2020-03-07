# frozen_string_literal: true

world_fraction = WorldFraction.first

race_ids = world_fraction.fraction.races.pluck(:id)

guild = Guild.create(world: world_fraction.world, fraction: world_fraction.fraction, world_fraction: world_fraction, name: 'Guild')

static = Static.create(world: world_fraction.world, fraction: world_fraction.fraction, world_fraction: world_fraction, name: 'Static', staticable: guild)

combination = Combination.where(combinateable_type: 'Race', combinateable_id: race_ids).first

dd = Role.find_by(name: { 'en' => 'Melee', 'ru' => 'Ближний бой' })

100.times do |index|
  user = User.create(email: "custom_#{index}@test.com", password: '12345QWErt', confirmed_at: DateTime.now)

  character = Character.create(name: index, level: 60, character_class: combination.character_class, race: combination.combinateable, user: user, world: world_fraction.world, world_fraction: world_fraction, guild: guild)

  CharacterRole.create(character: character, role: dd, main: true)

  StaticMember.create(static: static, character: character)
end
