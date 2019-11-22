class ModifyDatabaseWithWorldFractions < ActiveRecord::Migration[5.2]
  def change
    fractions = Fraction.all.to_a
    worlds = World.all.to_a

    fractions.each do |fraction|
      worlds.each do |world|
        WorldFraction.create(world: world, fraction: fraction)
      end
    end

    Character.find_each do |character|
      character.update(world_fraction: WorldFraction.find_by(world_id: character.world_id, fraction_id: character.race.fraction_id))
    end

    Guild.find_each do |guild|
      guild.update(world_fraction: WorldFraction.find_by(world_id: guild.world_id, fraction_id: guild.fraction_id))
    end

    Static.find_each do |static|
      static.update(world_fraction: WorldFraction.find_by(world_id: static.world_id, fraction_id: static.fraction_id))
    end

    Event.find_each do |event|
      world_id = event.eventable_type == 'World' ? event.eventable_id : event.eventable.world_id
      event.update(world_fraction: WorldFraction.find_by(world_id: world_id, fraction_id: event.fraction_id))
    end
  end
end
