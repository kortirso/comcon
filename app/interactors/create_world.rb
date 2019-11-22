# Create world
class CreateWorld
  include Interactor

  # required context
  # context.world_params
  def call
    world_form = WorldForm.new(context.world_params)
    if world_form.persist?
      context.world = world_form.world
    else
      context.fail!(message: world_form.errors.full_messages)
    end
  end

  def rollback
    context.world.destroy
  end
end
