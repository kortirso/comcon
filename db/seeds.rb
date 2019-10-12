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
