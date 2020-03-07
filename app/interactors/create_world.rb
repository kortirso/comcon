# frozen_string_literal: true

# Create world
class CreateWorld
  include Interactor

  # required context
  # context.world_params
  def call
    world_form = WorldDryForm.new(context.world_params.merge(id: nil))
    if world_form.save
      context.world = world_form.world
    else
      context.fail!(message: world_form.errors)
    end
  end

  def rollback
    context.world.destroy
  end
end
