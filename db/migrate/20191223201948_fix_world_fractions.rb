class FixWorldFractions < ActiveRecord::Migration[5.2]
  def change
    fractions = Fraction.all.to_a
    worlds = World.all.to_a

    fractions.each do |fraction|
      worlds.each do |world|
        WorldFraction.create(world: world, fraction: fraction) if WorldFraction.find_by(world_id: world.id, fraction_id: fraction.id).nil?
      end
    end
  end
end
