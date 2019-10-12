fraction_form = FractionForm.new(name: { 'en' => 'Alliance', 'ru' => 'Альянс' })
fraction_form.persist?

fraction_form = FractionForm.new(name: { 'en' => 'Horde', 'ru' => 'Орда' })
fraction_form.persist?
