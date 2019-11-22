# Create combination world and fraction
class CreateWorldFractions
  include Interactor

  # required context
  # context.world
  def call
    Fraction.find_each do |fraction|
      world_fraction_form = WorldFractionForm.new(world: context.world, fraction: fraction)
      context.fail!(message: world_fraction_form.errors.full_messages) unless world_fraction_form.persist?
    end
  end
end
