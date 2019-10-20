fraction_form = FractionForm.new(name: { 'en' => 'Alliance', 'ru' => 'Альянс' })
fraction_form.persist?
alliance = fraction_form.fraction

race_form = RaceForm.new(name: { 'en' => 'Human', 'ru' => 'Человек' }, fraction: alliance)
race_form.persist?
human = race_form.race
race_form = RaceForm.new(name: { 'en' => 'Dwarf', 'ru' => 'Дворф' }, fraction: alliance)
race_form.persist?
dwarf = race_form.race
race_form = RaceForm.new(name: { 'en' => 'Gnome', 'ru' => 'Гном' }, fraction: alliance)
race_form.persist?
gnome = race_form.race
race_form = RaceForm.new(name: { 'en' => 'Night Elf', 'ru' => 'Ночной Эльф' }, fraction: alliance)
race_form.persist?
night_elf = race_form.race

fraction_form = FractionForm.new(name: { 'en' => 'Horde', 'ru' => 'Орда' })
fraction_form.persist?
horde = fraction_form.fraction

race_form = RaceForm.new(name: { 'en' => 'Orc', 'ru' => 'Орк' }, fraction: horde)
race_form.persist?
orc = race_form.race
race_form = RaceForm.new(name: { 'en' => 'Troll', 'ru' => 'Тролль' }, fraction: horde)
race_form.persist?
troll = race_form.race
race_form = RaceForm.new(name: { 'en' => 'Tauren', 'ru' => 'Таурен' }, fraction: horde)
race_form.persist?
tauren = race_form.race
race_form = RaceForm.new(name: { 'en' => 'Undead', 'ru' => 'Нежить' }, fraction: horde)
race_form.persist?
undead = race_form.race

character_class_form = CharacterClassForm.new(name: { 'en' => 'Druid', 'ru' => 'Друид' })
character_class_form.persist?
druid = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Hunter', 'ru' => 'Охотник' })
character_class_form.persist?
hunter = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Mage', 'ru' => 'Маг' })
character_class_form.persist?
mage = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Paladin', 'ru' => 'Паладин' })
character_class_form.persist?
paladin = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Priest', 'ru' => 'Жрец' })
character_class_form.persist?
priest = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Rogue', 'ru' => 'Разбойник' })
character_class_form.persist?
rogue = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Shaman', 'ru' => 'Шаман' })
character_class_form.persist?
shaman = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Warlock', 'ru' => 'Чернокнижник' })
character_class_form.persist?
warlock = character_class_form.character_class
character_class_form = CharacterClassForm.new(name: { 'en' => 'Warrior', 'ru' => 'Воин' })
character_class_form.persist?
warrior = character_class_form.character_class

[druid, hunter, shaman, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: tauren)
  combination_form.persist?
end
[rogue, warlock, hunter, shaman, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: orc)
  combination_form.persist?
end
[rogue, hunter, paladin, priest, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: dwarf)
  combination_form.persist?
end
[mage, priest, rogue, warlock, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: undead)
  combination_form.persist?
end
[mage, paladin, priest, rogue, warlock, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: human)
  combination_form.persist?
end
[hunter, mage, priest, rogue, shaman, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: troll)
  combination_form.persist?
end
[druid, hunter, priest, rogue, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: night_elf)
  combination_form.persist?
end
[mage, rogue, warlock, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: gnome)
  combination_form.persist?
end

world_form = WorldForm.new(name: 'Хроми', zone: 'RU')
world_form.persist?

guild_form = GuildForm.new(name: 'КомКон', world: world_form.world, fraction: alliance)
guild_form.persist?

world_form = WorldForm.new(name: 'Рок-Делар', zone: 'RU')
world_form.persist?

guild_form = GuildForm.new(name: 'КомКон', world: world_form.world, fraction: horde)
guild_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Molten Core', 'ru' => 'Огненные Недра' }, raid: true, quest_access: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => "Onyxia's Lair", 'ru' => 'Логово Ониксии' }, raid: true, quest_access: true)
dungeon_form.persist?

role_form = RoleForm.new(name: { 'en' => 'Tank', 'ru' => 'Танк' })
role_form.persist?
tank = role_form.role

role_form = RoleForm.new(name: { 'en' => 'Healer', 'ru' => 'Целитель' })
role_form.persist?
healer = role_form.role

role_form = RoleForm.new(name: { 'en' => 'Melee', 'ru' => 'Ближний бой' })
role_form.persist?
melee = role_form.role

role_form = RoleForm.new(name: { 'en' => 'Ranged', 'ru' => 'Дальний бой' })
role_form.persist?
ranged = role_form.role

[druid, paladin, warrior].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: tank)
  combination_form.persist?
end
[paladin, priest, shaman, druid].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: healer)
  combination_form.persist?
end
[rogue, warrior, paladin, druid, shaman].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: melee)
  combination_form.persist?
end
[mage, priest, druid, warlock, shaman, hunter].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable: ranged)
  combination_form.persist?
end
