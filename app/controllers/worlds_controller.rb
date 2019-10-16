class WorldsController < ApplicationController
  before_action :find_worlds, only: %i[index]
  before_action :find_world, only: %i[edit update destroy]

  def index
    authorize!
  end

  def new
    authorize!
  end

  def create
    authorize!
    world_form = WorldForm.new(world_params)
    return redirect_to worlds_path if world_form.persist?
    render :new
  end

  def edit
    authorize!
  end

  def update
    authorize!
    world_form = WorldForm.new(@world.attributes.merge(world_params))
    return redirect_to worlds_path if world_form.persist?
    render :edit
  end

  def destroy
    authorize!
    @world.destroy
    redirect_to worlds_path, status: 303
  end

  private

  def find_worlds
    @worlds = World.order(name: :asc)
  end

  def find_world
    @world = World.find_by(id: params[:id])
    render_error('Object is not found') if @world.nil?
  end

  def world_params
    params.require(:world).permit(:name, :zone)
  end
end
