# frozen_string_literal: true

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
race_form = RaceForm.new(name: { 'en' => 'Draenei', 'ru' => 'Дреней' }, fraction: alliance)
race_form.persist?
draenei = race_form.race

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
race_form = RaceForm.new(name: { 'en' => 'Blood Elf', 'ru' => 'Эльф крови' }, fraction: horde)
race_form.persist?
blood_elf = race_form.race

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

world_form = WorldDryForm.new(id: nil, name: 'Хроми', zone: 'RU')
world_form.save

guild_form = GuildForm.new(name: 'КомКон', world: world_form.world, fraction: alliance)
guild_form.persist?

world_form = WorldDryForm.new(id: nil, name: 'Рок-Делар', zone: 'RU')
world_form.save

guild_form = GuildForm.new(name: 'КомКон', world: world_form.world, fraction: horde)
guild_form.persist?

fractions = Fraction.all.to_a
worlds = World.all.to_a

fractions.each do |fraction|
  worlds.each do |world|
    WorldFraction.create(world: world, fraction: fraction) if WorldFraction.find_by(world_id: world.id, fraction_id: fraction.id).nil?
  end
end

dungeon_form = DungeonForm.new(name: { 'en' => 'Molten Core', 'ru' => 'Огненные Недра' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => "Onyxia's Lair", 'ru' => 'Логово Ониксии' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Ragefire Chasm', 'ru' => 'Огненная пропасть' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Deadmines', 'ru' => 'Мертвые копи' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Wailing Caverns', 'ru' => 'Пещеры Стенаний' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Shadowfang Keep', 'ru' => 'Крепость Темного Клыка' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Blackfathom Deeps', 'ru' => 'Непроглядная Пучина' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Stockade', 'ru' => 'Тюрьма' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Gnomeregan', 'ru' => 'Гномреган' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Razorfen Kraul', 'ru' => 'Лабиринты Иглошкурых' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Scarlet Monastery', 'ru' => 'Монастырь Алого ордена' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Razorfen Downs', 'ru' => 'Курганы Иглошкурых' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Uldaman', 'ru' => 'Ульдаман' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => "Zul'Farrak", 'ru' => "Зул'Фаррак" })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Sunken Temple', 'ru' => 'Затонувший храм' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Blackrock Depths', 'ru' => 'Глубины Черной горы' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Upper Blackrock Spire', 'ru' => 'Вершина Черной горы (верхняя часть)' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Lower Blackrock Spire', 'ru' => 'Вершина Черной горы (нижняя часть)' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Stratholme (living)', 'ru' => 'Стратхольм (живой)' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Stratholme (undead)', 'ru' => 'Стратхольм (мертвый)' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Dire Maul', 'ru' => 'Забытый Город' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Scholomance', 'ru' => 'Некроситет' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Maraudon', 'ru' => 'Мародон' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Blackwing Lair', 'ru' => 'Логово Крыла Тьмы' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Zul’Gurub', 'ru' => 'Зул’Гуруб' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Ruins of Ahn’Qiraj', 'ru' => 'Руины Ан’Киража' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Temple of Ahn’Qiraj', 'ru' => 'Храм Ан’Киража' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Naxxramas', 'ru' => 'Наксрамас' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Hellfire Ramparts', 'ru' => 'Бастионы Адского Пламени' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Blood Furnace', 'ru' => 'Кузня Крови' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Slave Pens', 'ru' => 'Узилище' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Underbog', 'ru' => 'Нижетопь' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Mana-Tombs', 'ru' => 'Гробницы маны' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Shattered Halls', 'ru' => 'Разрушенные залы' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Sethekk Halls', 'ru' => 'Сетеккские залы' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Steamvault', 'ru' => 'Паровое подземелье' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Auchenai Crypts', 'ru' => 'Аукенайские гробницы' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Shadow Labyrinth', 'ru' => 'Темный лабиринт' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Mechanar', 'ru' => 'Механар' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Arcatraz', 'ru' => 'Аркатрац' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'The Botanica', 'ru' => 'Ботаника' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => "Magisters' Terrace", 'ru' => 'Терраса Магистров' })
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Karazhan', 'ru' => 'Каражан' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => "Gruul's Lair", 'ru' => 'Логово Груула' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => "Magtheridon's Lair", 'ru' => 'Логово Магтеридона' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Serpentshrine Cavern', 'ru' => 'Змеиное святилище' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Sunwell Plateau', 'ru' => 'Плато Солнечного Колодца' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Black Temple', 'ru' => 'Черный храм' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Tempest Keep', 'ru' => 'Крепость Бурь' }, raid: true)
dungeon_form.persist?

dungeon_form = DungeonForm.new(name: { 'en' => 'Hyjal Summit', 'ru' => 'Вершина Хиджала' }, raid: true)
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
  combination_form = CombinationForm.new(character_class: character_class, combinateable_id: tank.id, combinateable_type: 'Role')
  combination_form.persist?
end
[paladin, priest, shaman, druid].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable_id: healer.id, combinateable_type: 'Role')
  combination_form.persist?
end
[rogue, warrior, paladin, druid, shaman].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable_id: melee.id, combinateable_type: 'Role')
  combination_form.persist?
end
[mage, priest, druid, warlock, shaman, hunter].each do |character_class|
  combination_form = CombinationForm.new(character_class: character_class, combinateable_id: ranged.id, combinateable_type: 'Role')
  combination_form.persist?
end

profession_form = ProfessionForm.new(name: { 'en' => 'Skinning', 'ru' => 'Снятие шкур' })
profession_form.persist?
_skinning = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Leatherworking', 'ru' => 'Кожевничество' }, recipeable: true)
profession_form.persist?
_leatherworking = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Herbalism', 'ru' => 'Травничество' })
profession_form.persist?
_herbalism = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Alchemy', 'ru' => 'Алхимия' }, recipeable: true)
profession_form.persist?
_alchemy = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Mining', 'ru' => 'Горное дело' })
profession_form.persist?
_mining = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Blacksmithing', 'ru' => 'Кузнечное дело' }, recipeable: true)
profession_form.persist?
_blacksmithing = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Engineering', 'ru' => 'Инженерное дело' }, recipeable: true)
profession_form.persist?
_engineering = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Tailoring', 'ru' => 'Портняжное дело' }, recipeable: true)
profession_form.persist?
_tailoring = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Enchanting', 'ru' => 'Наложение чар' }, recipeable: true)
profession_form.persist?
_enchanting = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Cooking', 'ru' => 'Кулинария' }, main: false, recipeable: true)
profession_form.persist?
_cooking = profession_form.profession

profession_form = ProfessionForm.new(name: { 'en' => 'Jewelcrafting', 'ru' => 'Ювелирное дело' }, recipeable: true)
profession_form.persist?
_jewelcrafting = profession_form.profession

notification_form = NotificationForm.new(name: { 'en' => 'Guild event creation', 'ru' => 'Создание гильдейского события' }, event: 'guild_event_creation', status: 0)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Guild event creation', 'ru' => 'Создание гильдейского события' }, event: 'guild_event_creation', status: 1)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Event will start soon', 'ru' => 'Скоро начнется событие' }, event: 'event_start_soon', status: 1)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Event creation for static', 'ru' => 'Создание события для статика' }, event: 'guild_static_event_creation', status: 0)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Event creation for static', 'ru' => 'Создание события для статика' }, event: 'guild_static_event_creation', status: 1)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Guild request creation', 'ru' => 'Создание заявки в гильдию' }, event: 'guild_request_creation', status: 0)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Guild request creation', 'ru' => 'Создание заявки в гильдию' }, event: 'guild_request_creation', status: 1)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Bank request creation', 'ru' => 'Создание заявки в банке' }, event: 'bank_request_creation', status: 0)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Bank request creation', 'ru' => 'Создание заявки в банке' }, event: 'bank_request_creation', status: 1)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Activity creation', 'ru' => 'Создание новости' }, event: 'activity_creation', status: 0)
notification_form.persist?

notification_form = NotificationForm.new(name: { 'en' => 'Activity creation', 'ru' => 'Создание новости' }, event: 'activity_creation', status: 1)
notification_form.persist?

Activity.create title: 'Снаряжение (Equipment)', description: "Доступна загрузка снаряжения для персонажей, пройдите к описанию вашего персонажа и импортируйте данные по инструкции. Import of character equipment is available, just go to your character's page and import data."

Activity.create title: 'Ан’Кираж (Ahn’Qiraj)', description: 'Рейды Ан’Киража доступны для создания событий. Raids of Ahn’Qiraj are available for event creation.'
