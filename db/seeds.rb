fraction_form = FractionForm.new(name: { 'en' => 'Alliance', 'ru' => 'Альянс' })
fraction_form.persist?

alliance = fraction_form.fraction
race_form = RaceForm.new(name: { 'en' => 'Human', 'ru' => 'Человек' }, fraction: alliance)
race_form.persist?
race_form = RaceForm.new(name: { 'en' => 'Dwarf', 'ru' => 'Дворф' }, fraction: alliance)
race_form.persist?
race_form = RaceForm.new(name: { 'en' => 'Gnome', 'ru' => 'Гном' }, fraction: alliance)
race_form.persist?
race_form = RaceForm.new(name: { 'en' => 'Night Elf', 'ru' => 'Ночной Эльф' }, fraction: alliance)
race_form.persist?

fraction_form = FractionForm.new(name: { 'en' => 'Horde', 'ru' => 'Орда' })
fraction_form.persist?

horde = fraction_form.fraction
race_form = RaceForm.new(name: { 'en' => 'Orc', 'ru' => 'Орк' }, fraction: horde)
race_form.persist?
race_form = RaceForm.new(name: { 'en' => 'Troll', 'ru' => 'Тролль' }, fraction: horde)
race_form.persist?
race_form = RaceForm.new(name: { 'en' => 'Tauren', 'ru' => 'Таурен' }, fraction: horde)
race_form.persist?
race_form = RaceForm.new(name: { 'en' => 'Undead', 'ru' => 'Нежить' }, fraction: horde)
race_form.persist?

character_class_form = CharacterClassForm.new(name: { 'en' => 'Druid', 'ru' => 'Друид' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Hunter', 'ru' => 'Охотник' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Mage', 'ru' => 'Маг' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Paladin', 'ru' => 'Паладин' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Priest', 'ru' => 'Жрец' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Rogue', 'ru' => 'Разбойник' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Shaman', 'ru' => 'Шаман' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Warlock', 'ru' => 'Чернокнижник' })
character_class_form.persist?
character_class_form = CharacterClassForm.new(name: { 'en' => 'Warrior', 'ru' => 'Воин' })
character_class_form.persist?

world_form = WorldForm.new(name: 'Хроми', zone: 'RU')
world_form.persist?

guild_form = GuildForm.new(name: 'КомКон', world: world_form.world, fraction: alliance)
guild_form.persist?

world_form = WorldForm.new(name: 'Рок-Делар', zone: 'RU')
world_form.persist?

guild_form = GuildForm.new(name: 'КомКон', world: world_form.world, fraction: horde)
guild_form.persist?
