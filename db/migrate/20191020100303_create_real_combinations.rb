class CreateRealCombinations < ActiveRecord::Migration[5.2]
  def change
    # find races
    human = Race.find_by(name: { 'en' => 'Human', 'ru' => 'Человек' })
    dwarf = Race.find_by(name: { 'en' => 'Dwarf', 'ru' => 'Дворф' })
    gnome = Race.find_by(name: { 'en' => 'Gnome', 'ru' => 'Гном' })
    night_elf = Race.find_by(name: { 'en' => 'Night Elf', 'ru' => 'Ночной Эльф' })
    orc = Race.find_by(name: { 'en' => 'Orc', 'ru' => 'Орк' })
    troll = Race.find_by(name: { 'en' => 'Troll', 'ru' => 'Тролль' })
    tauren = Race.find_by(name: { 'en' => 'Tauren', 'ru' => 'Таурен' })
    undead = Race.find_by(name: { 'en' => 'Undead', 'ru' => 'Нежить' })
    # find roles
    tank = Role.find_by(name: { 'en' => 'Tank', 'ru' => 'Танк' })
    healer = Role.find_by(name: { 'en' => 'Healer', 'ru' => 'Целитель' })
    melee = Role.find_by(name: { 'en' => 'Melee', 'ru' => 'Ближний бой' })
    ranged = Role.find_by(name: { 'en' => 'Ranged', 'ru' => 'Дальний бой' })
    # fine character_classes
    druid = CharacterClass.find_by(name: { 'en' => 'Druid', 'ru' => 'Друид' })
    hunter = CharacterClass.find_by(name: { 'en' => 'Hunter', 'ru' => 'Охотник' })
    mage = CharacterClass.find_by(name: { 'en' => 'Mage', 'ru' => 'Маг' })
    paladin = CharacterClass.find_by(name: { 'en' => 'Paladin', 'ru' => 'Паладин' })
    priest = CharacterClass.find_by(name: { 'en' => 'Priest', 'ru' => 'Жрец' })
    rogue = CharacterClass.find_by(name: { 'en' => 'Rogue', 'ru' => 'Разбойник' })
    shaman = CharacterClass.find_by(name: { 'en' => 'Shaman', 'ru' => 'Шаман' })
    warlock = CharacterClass.find_by(name: { 'en' => 'Warlock', 'ru' => 'Чернокнижник' })
    warrior = CharacterClass.find_by(name: { 'en' => 'Warrior', 'ru' => 'Воин' })
    # create race combination
    [druid, hunter, shaman, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: tauren.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [rogue, warlock, hunter, shaman, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: orc.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [rogue, hunter, paladin, priest, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: dwarf.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [mage, priest, rogue, warlock, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: undead.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [mage, paladin, priest, rogue, warlock, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: human.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [hunter, mage, priest, rogue, shaman, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: troll.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [druid, hunter, priest, rogue, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: night_elf.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    [mage, rogue, warlock, warrior].each do |character_class|
      combination_form = CombinationForm.new(character_class: character_class, combinateable_id: gnome.id, combinateable_type: 'Race')
      combination_form.persist?
    end
    # create role combination
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
  end
end
